class StudiesController < ApplicationController

  before_filter :authorize

  include Fetch

 
  def get_query(term)
    if term.match(/^\d+$/)
      return ["title ~ ? or authors ~ ? or year = ? or pmid = ? or id = ?", term, term, term, term, term]
    else
      return ["lower(title) ~ ? or lower(authors) ~ ?",  term.downcase, term.downcase]
    end
  end

  def add_to_session
    session[:studies].push(params[:id].to_i) if Study.find(params[:id]) and !session[:studies].include?(params[:id].to_i)
    render :partial => 'cart'
  end

  def del_from_session
    session[:studies] = session[:studies].delete_if{|e| e==params[:id].to_i}
    render :partial => 'cart'
  end
  
  def autocomplete
    to_render = []
    final_list=[]
    list_terms = params[:term].split(/\s+/)
    
    query = get_query(list_terms[0]) #"title ~ ? or authors ~ ? or year = ? or pmid = ?"
    final_list= Study.find(:all, 
                           :conditions => query)
    (1 .. list_terms.size-1).each do |i|
      term = list_terms[i]
      query = get_query(term)
      studies = Study.find(:all, :conditions => query)
      final_list &= studies
    end

    to_render = final_list.map{|e| 
      tab_add_data = []
      tab_add_data.push(e.organism.name) if e.organism
      tab_add_data.push(e.cell_type.name) if e.cell_type
      tab_add_data.push(e.subcellular_fraction.name) if e.subcellular_fraction
      tab_add_data.push(e.techniques.map{|t| t.name}.join(",")) if e.techniques.size > 0
      {:id => e.id, :label => "##{e.id}: #{e.year} #{e.authors} #{e.title.first(20)}... #{tab_add_data.join(";")}"}}
    render :text => to_render.to_json    
  end

  def load_article

    @results = {}

    if params[:pmid]
      @results = fetch_pubmed(params[:pmid])
    end
    
    respond_to do |format|
      format.json{ render json: @results }# index.html.erb                                          
    end
  end

  # GET /studies
  # GET /studies.json
  def index
    h_bool = {'0' => false, '1' => true}

    @h_confidence_levels = {}
    ConfidenceLevel.all.each do |cl|
      @h_confidence_levels[cl.id]=cl
    end

    @large_scale = (params[:large_scale] and params[:large_scale]=='1') ? true : false

    @studies = Study.all
    
    @studies.reject!{|e| e.hidden == true} if !admin? and !lab_user?

    @studies.reject!{|e| e.large_scale != h_bool[params[:large_scale]] } if params[:large_scale] 

    @h_hits_with_sites = {}
    Hit.find(:all, :conditions => {:has_site => true}).each do |h|
      @h_hits_with_sites[h.study_id]||=[]
      @h_hits_with_sites[h.study_id].push(h)
    end

    
#    @h_sites_by_study_id={}
#    Site.all.each do |site|
#      @h_sites_by_study_id[h_hits_by_study_id[site.hit_id]]||=[]
#      @h_sites_by_study_id[h_hits_by_study_id[site.hit_id]].push(site)
#    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @studies }
    end
  end

  # GET /studies/1
  # GET /studies/1.json
  def show
    @study = Study.find(params[:id])

    if @study.hidden == false or (admin? or lab_user?)
      
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @study }
      end
    else
      render :nothing => true
    end
  end

  # GET /studies/new
  # GET /studies/new.json
  def new
    @study = Study.new

    if params[:large_scale]
      @study.large_scale = (params[:large_scale]=='1') ? true : false
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @study }
    end
  end

  def new_large_scale
    @study = Study.new

    respond_to do |format|
      format.html  #new_large_scale.html.erb        
      format.json { render json: @study }
    end
  end


  # GET /studies/1/edit
  def edit
    @study = Study.find(params[:id])    
  end

  # POST /studies
  # POST /studies.json
  def create
    @study = Study.new(params[:study])
    @study.user_id = current_user.id
    respond_to do |format|
      if @study.save
        format.html { redirect_to @study, notice: 'Study was successfully created.' }
        format.json { render json: @study, status: :created, location: @study }
      else
        format.html { render action: "new" }
        format.json { render json: @study.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /studies/1
  # PUT /studies/1.json
  def update
    @study = Study.find(params[:id])

    @study.technique_ids= params[:study][:technique_ids]

    respond_to do |format|
      if @study.update_attributes(params[:study])
        format.html { redirect_to @study, notice: 'Study was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @study.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /studies/1
  # DELETE /studies/1.json
  def destroy
    @study = Study.find(params[:id])
    @study.hits.destroy_all
    @study.history_studies.destroy_all
    @study.destroy

    respond_to do |format|
      format.html { redirect_to studies_url }
      format.json { head :no_content }
    end
  end
end
