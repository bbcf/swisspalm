class SitesController < ApplicationController

  include Fetch
  include AddUpdate
  include LoadData

  def meta_edit
    h={}
    if params[:hit_id]
      hit = Hit.find(params[:hit_id])
      study = hit.study
      tab_add_data = []
      tab_add_data.push(study.organism.name) if study.organism
      tab_add_data.push(study.cell_type.name) if study.cell_type
      tab_add_data.push(study.subcellular_fraction.name) if study.subcellular_fraction
      tab_add_data.push(study.techniques.map{|t| t.name}.join(",")) if study.techniques.size > 0
      article = Article.find_by_pmid(study.pmid)
      h[:study_text]="##{study.id}: #{article.year} #{article.authors} #{article.title.first(20)}... #{tab_add_data.join(";")}"
      h[:study_id]=hit.study.id
      h[:protein_text]=hit.protein.up_ac
      h[:protein_id]=hit.protein_id      
      params[:transferase_text]= hit.reactions.select{|r| r.is_a_pat == true}.map{|r| r.protein.up_ac}.join(",")
      params[:esterase_text]= hit.reactions.select{|r| r.is_a_pat == false}.map{|r| r.protein.up_ac}.join(",")

      if params[:site_id]
        site = Site.find(params[:site_id])
        h[:pos] =site.pos
        h[:uncertain_pos]=site.uncertain_pos
        params[:transferase_text]= site.reactions.select{|r| r.is_a_pat == true}.map{|r| r.protein.up_ac}.join(",") if site.reactions.size > 0
        params[:esterase_text]= site.reactions.select{|r| r.is_a_pat == false}.map{|r| r.protein.up_ac}.join(",") if site.reactions.size > 0
        h[:technique_ids]=site.techniques.map{|e| e.id}
      end
    end
    @site=Site.new(h)
    respond_to do |format|
      format.html { render :action => :new}
    end
    
  end

  def upd_form

    @results = {}

    hit_lists = []

    if params[:study_text] and m = params[:study_text].match(/^\#(\d+)/)
      study = Study.find(m[1].to_i)
      hit_lists = study.hit_lists if study
    end

    isoforms = []
    if params[:up_ac] and  params[:up_ac] != ''
      protein = Protein.find_by_up_ac(params[:up_ac])
      isoforms= protein.isoforms.select{|i| i.latest_version} if protein
    end

    @results={
      :protein_id => (protein) ? protein.id : nil,
      :study_id => (study) ? study.id : nil,
      :hit_lists => hit_lists.map{|e| [e.id, [((e.confidence_level) ? e.confidence_level.name : nil), e.label, ((!e.confidence_level and e.label == '') ? 'No name' : nil)].select{|e| e and e != ''}.join(" ")]},
      :isoforms => isoforms.map{|e| e.isoform},
      :organism_id =>  (study) ? study.organism_id : nil ,
      :cell_type_id => (study) ? study.cell_type_id : nil,
      :subcellular_fraction =>  (study) ? study.subcellular_fraction_id : nil
    }
    respond_to do |format|
      format.json{ render json: @results }# index.html.erb                                           
    end

  end

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all
    @sites.reject!{|s| s.hit.study.hidden == true} if !admin? and !lab_user?
    respond_to do |format|
      format.html # index.html.erb
      format.text {
        txt = ["SPalmS ID", "Uniprot AC", 'Isoform', "Position"].join("\t") + "\n";
        txt += @sites.map{|s| ["SPalmS#{s.id}", s.hit.protein.up_ac, ((s.hit.isoform) ? s.hit.isoform.isoform : ((s.hit.protein.isoforms.select{|e| e.latest_version and e.main}.first) ? s.hit.protein.isoforms.select{|e| e.latest_version and e.main}.first.isoform : 'NA' )),  s.pos].join("\t")}.join("\n")
        render text: txt
      }
      format.json { render json: @sites }
    end
  end

  # GET /sites                                                                            
  # GET /sites.json                                                                                                                                                                                             
  def index_by_hit
#    @sites = Site.all
    @hits = Hit.find(:all, :joins => 'right join sites on (sites.hit_id = hits.id)')
    respond_to do |format|
      format.html #render index_.html.erb                                                                                                                                                    
      format.json { render json: @sites }
    end
  end


  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = Site.find(params[:id])

    if @site.hit.study.hidden == false or (admin? or lab_user?)    
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @site }
      end
    else
      render :nothing => true
    end
  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = Site.new    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end
  

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(params[:site])
    site = Site.new(params[:site])
    nber_sites=0
    nber_updated_sites=0
    
    logger.debug('test')
    #    begin 
    if site.study_id and site.protein_id and site.isoform_text
      
      study = Study.find(site.study_id)
      # logger.debug(site.protein_id)
       logger.debug("-" + params[:site][:protein_text] + "-")
      if site.protein_id != ''
        protein = Protein.find(site.protein_id)
      elsif params[:site][:protein_text]
        h_res = fetch_uniprot_entry(params[:site][:protein_text])
        h_prot = h_res[:h_protein]
       
        logger.debug(h_prot.to_json)

        protein = Protein.find(:first, :conditions => {:up_ac => h_prot[:up_ac]})
        if !protein
          logger.debug("testblou")
          logger.debug(h_prot.to_json)
          protein = Protein.new(h_prot)
          protein.user_id=current_user.id
          if protein.save
          else
            raise "Protein validation error"
          end
        end
      end
      logger.debug('bla')
      h_seq =  fetch_uniprot_seq(protein.up_ac)            
#      add_update_sequence(protein, h_seq)
      create_isoforms(h_seq, protein)

      logger.debug('test2')
      
      list_isoforms = site.isoform_text.split(",").map{|e| 
        t = e.split("-"); 
        t[1] = t[0] if t.size ==1 
        (t[0].to_i .. t[1].to_i).to_a
      }.flatten
      
      list_isoforms = [-1] if list_isoforms.size == 0
      
      list_isoforms.each do |iso|
        
        ### create hit                                                                                             
        #  logger.debug(iso.to_json + " -- "  + protein.to_json)
        
        isoform = Isoform.find(:first, :conditions => {:protein_id => protein.id, :isoform => iso}) if iso != -1
        
        h_hit = {
          :protein_id => protein.id,
          #          :hit_list_id => nil,
          :study_id => study.id,
          :isoform_id => (isoform) ? isoform.id : nil
        }
        
        hit = Hit.find(:first, :conditions => h_hit)
        if !hit
          h_hit[:curator_id]=current_user.id
          h_hit[:hit_list_id]=nil
          hit = Hit.new(h_hit)
          if hit.save
          else
            raise "Hit validation error"
          end            
        end
        if hit
          #            techniques = Technique.find(params[:hit][:technique_ids])
          #            techniques.select{|t|!hit.techniques.include?(t)}.each do |technique|
          #              hit.techniques << technique
          #            end
        end
        ### create sites and associated reactions                                                                                                                                                                                 
        #          logger.debug('tataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
        
        if hit
          
          list_pos = params[:site][:pos].strip.split(/,/)
          
          if list_pos.size > 0
            #logger.debug("List pos :" + list_pos.join(","));
            list_pos.each do |pos_range|
              # logger.debug("Pos range:" + pos_range.to_s)
              t=pos_range.split("-")
              if t.size == 1
                t[1] = t[0]
              end
              (t[0].to_i .. t[1].to_i).to_a.each do |pos|
                #  logger.debug("Pos:" + pos.to_s)
                h_site={
                  :hit_id => hit.id,
                  :pos => pos
                  #            #  :in_uniprot => true
                }
                #            logger.debug('blouuuuuuuuuuuuuu')
                @site = Site.find(:first, :conditions => h_site)
                if !@site
                  @site = Site.new(params[:site])
                  @site.pos = pos
                  #h_site[:curator_id]=current_user.id
                  # h_site.each_key do |k|
                  # site = Site.new(h_site) 
                  @site.curator_id = current_user.id
                  @site.user_id = current_user.id
                  @site.hit_id = hit.id
                  # @site = Site.new(h_site)
                  # end
                  #              @site = Site.new(h_site)
                  if @site.save
                    nber_sites+=1
                  else
                    # @site.errors = site.errors
                    #                 @site.transferase_text = params[:transferase_text]
                    #               @site.
                    raise "Site validation error"
                  end
                else
                  @site.update_attributes({:user_id=> current_user.id, :uncertain_pos =>params[:site][:uncertain_pos]})
                  #             logger.debug('totooooooooooooooooooooooo')
                  nber_updated_sites+=1
                end
                if @site
                  add_update_reactions(hit, @site, site.transferase_text, true)
                  add_update_reactions(hit, @site, site.esterase_text, false)
                  if params[:site][:technique_ids]
                    techniques = Technique.find(params[:site][:technique_ids])
                    techniques.select{|t| !@site.techniques.include?(t)}.each do |technique|
                      @site.techniques << technique
                    end
                  end
                end
              end
            end
          else
            add_update_reactions(hit, nil, site.transferase_text, true)
            add_update_reactions(hit, nil, site.esterase_text, false)
          end
        end
      end
    end
    
    respond_to do |format|
      flash[:notice] = "#{nber_sites} sites created; #{nber_updated_sites} sites updated."
      format.html { redirect_to controller: 'hits', action: 'index' }
      #format.json { render json: @site, status: :created, location: @site }                                                                                                                                                        
    end
    
    #    rescue Exception => e
    #      respond_to do |format|
    #        flash[:notice] = e.backtrace
    #        #        @site.transferase_text = site.transferase_text
    #        #        @site.study_text = site.study_text
    #        #       @site.protein_text = site.protein_text
    #        #       @site.isoform_text = site.isoform_text
    #        format.html { render action: "new" }
    #      end
    #    end
  end
  
  
  
  # PUT /sites/1
  # PUT /sites/1.json
  def update
    @site = Site.find(params[:id])
    
       
    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end
end
