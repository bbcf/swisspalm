class ProteinsController < ApplicationController
  autocomplete :ref_protein, :value, :full => true

# def get_autocomplete_items(parameters)
#    items = super(parameters)
#    #conditions = (params[:action] == 'autocomplete_synonym_value') ? "expression_data is true" : "acc != name and in_flybase is true"
#   items.select{|e| e.protein}.map{|e| e.protein}.uniq! #if params[:gene_name]                                                                                                                                                                                         
    #      item = items.where('acc != name') if params[:go_term]                                                                                                                                                                                  
#  end#

  def upd_cart
    if params[:id] and Protein.find(params[:id]) 
      if !session[:proteins][params[:id].to_i]
        session[:proteins][params[:id].to_i]=1 
      else
        session[:proteins].delete(params[:id].to_i) #session[:proteins].select{|e| e==params[:id].to_i}
      end
    end
    render :partial => 'cart'
  end


  def change_db
 
    session[:search_db]=params[:db]
    if params[:organism_id] and params[:organism_id]!=''
      session[:organism_id]=params[:organism_id].to_i  
    else
      session[:organism_id]=nil
    end
    render :nothing => true

  end


  def autocomplete

    threshold = 15

    search_db_query = ''
    if session[:search_db] == 'palm'
      search_db_query = ' and has_hits = ?' 
      #    elsif session[:search_db] == 'pred'
      #      search_db_query = ' and has_hc_pred = ?'
    end
  #  search_db_query += ((lab_user?) ? ' and nber_technique_categories_labuser' : ' and nber_technique_categories_public') + "  > 1" if session[:search_db] == 'meth' 
    search_db = (session[:search_db] == 'palm' or session[:search_db] == 'meth' or session[:seasrch_db] == 'meth2') ? true : nil
  #  search_db_query += ( session[:organism_id]) ? ' and organism_id = ?' : ''
  #  organism_id = session[:organism_id]

    to_render = []
    h_status = {
      0 => 'Experimental evidence',
      1 => 'By similarity',
      2 => 'Probable',
      3 => 'Potential'
    }    
    
    terms = params[:term].split(" and ")
    
    unfound_part=(0 .. terms.size-2).to_a.map{|i| terms[i]}.join(' and ')
    unfound_part += " and " if unfound_part != ''
    
    term = terms.map{|e| e.strip}.last

    if m = term.match(/^GO:(.+)/)
      
      go_terms =  GoTerm.find(:all, :conditions => ['lower(name) ~ ?', m[1].downcase])
      to_render = go_terms.sort{| a, b| [a.name.size, a.name]  <=> [b.name.size, b.name]}.map{|go_term| {:id => go_term.id, :label => unfound_part + "GO:#{go_term.name}"}}

    elsif m = term.match(/^Gene:(.+)/)
      gene_names = RefProtein.find(:all, :select => "value", :joins => 'join source_types on (source_types.id = source_type_id)', :conditions => ["lower(value) ~ ? and name = 'gene_name'", m[1].downcase]).map{|e| [e.id, e.value]}.uniq
      to_render = gene_names.sort{| a, b| [a[1].size, a[1]]  <=> [b[1].size, b[1]]}.map{|gene_name| {:id => gene_name[0], :label => unfound_part + "Gene:#{gene_name[1]}"}}
    elsif  m = term.match(/^Subcellular:(.+)/)
      subcellulars =  SubcellularLocation.find(:all, :conditions => ['lower(name) ~ ?', m[1].downcase])
      to_render = subcellulars.sort{| a, b| [a.name.size, a.name]  <=> [b.name.size, b.name]}.map{|subcellular| {:id => subcellular.id, :label => unfound_part + "Subcellular:#{subcellular.name} (>= #{h_status[subcellular.status]})"}}
    elsif !term.match(/^Motif:(.*)/)

      global_subterms = term.split(/,/).map{|e| e.split(/[\s\(\),;\:]+/).uniq}
      
      #    list_proteins = search(global_subterms)
      #    if list_proteins.size > 0
      
      global_res = []
      valid_part = []
      
      res = []
      
      if global_subterms.size > 1
        
        res = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , global_subterms[0].join(' ').downcase, search_db].compact).map{|e| e.protein_ids.split(',')}.flatten.uniq || []
        valid_part.push((res.size ==0) ? false : true)
        if global_subterms.size > 2
          (1 .. global_subterms.size-2).to_a.each do |i|
            st = global_subterms[i]
            #        op = (i == global_subterms.size-1) ? '~' : '='
            local_res = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , st.join(' ').downcase, search_db].compact).map{|e| e.protein_ids.split(',')}.flatten.uniq || []
            global_res.push(local_res)
            res &= local_res
            valid_part.push((res.size ==0) ? false : true)
          end
        end
      end
      
      if  global_subterms.size ==1 || res.size > 0
        
        subterms = global_subterms.last
        words = []
        #   words2= []
        unfound_level = nil
        shift = 0
        (0 .. subterms.size-1).to_a.each do |i|
          expr = (shift .. i).to_a.map{|j| subterms[j]}.join(" ").strip
          logger.debug("#{search_db_query} #{search_db} #{expr.downcase}")
          tmp_words = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , expr.downcase, search_db].compact)  
          if tmp_words.size == 0  #and tmp_words2.size ==0
            unfound_level = i-shift
            if i > shift
              global_subterms.pop
              new_global_subterm = (shift .. i-1).to_a.map{|j| subterms[j]}
              local_res = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , new_global_subterm.join(' ').downcase, search_db].compact).map{|e| e.protein_ids.split(',')}.flatten.uniq || []
              if res.size == 0
                res = local_res 
              else
                res &= local_res
              end
              valid_part.push((res.size ==0) ? false : true)
              global_subterms.push(new_global_subterm, (i .. subterms.size-1).to_a.map{|j| subterms[j]})
              shift=i
              
              expr = (shift .. i).to_a.map{|j| subterms[j]}.join(" ").strip
              tmp_words = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , expr.downcase, search_db].compact)
            end
          end
          words = tmp_words
          #      words2 = tmp_words2
        end
        subterms = global_subterms.last
        
        
        #      res_by_word = Word.find(words.map{|w| w.id}}
        
        final_words = []
        
        if global_subterms.size > 1
          logger.debug (res.size.to_s + ", " + words.to_s) 
          words.each do |w|
            tmp_res = res & w.protein_ids.split(',')
            final_words.push(w) if tmp_res.size > 0
          end
        else
          final_words = words
        end
       #valid_part.push((res.size ==0) ? false : true)
        
        
        if global_subterms.size > 1
          #        unfound_part = (0 .. global_subterms.size-2).to_a.map{|i|"<span style='font-weight=#{valid_part[i]}'>" +  global_subterms[i].join(" ") + "</span>"}.join(", ")  + ", "
          unfound_part = (0 .. global_subterms.size-2).to_a.map{|i|  global_subterms[i].join(" ")}.join(", ")  + ", " 
        end
        #  if unfound_level 
        #    _part += (0 .. subterms.size-1 - unfound_level).to_a.map{|i| subterms[i]}.join(" ") + ", "
        #  end
        
        
        
        final_words = final_words.sort!{|a, b| a.value.size <=> b.value.size}# + words2.sort!{|a, b| a.value.size <=> b.value.size}
        nber_words = final_words.size
        if nber_words > threshold
          final_words = final_words.first(threshold)
        end
        
        
        log = global_subterms.size.to_s + ", " + unfound_level.to_s + ", " + res.size.to_s
        to_render =  final_words.map{|w| {:id => w.id, :label =>  unfound_part + w.value}}
        # label = ''
        # label = 'No results' if nber_words == 0 
        # label = (nber_words-threshold).to_s + ' more' if nber_words >threshold
        # to_render.push({:id => nil, :label => label})  if  label != ''
        # to_render.push({:id => nil, :label => log})                                                                                                                                                                                                   
     # else
      #   to_render = [] #[{:id => nil, :label => 'No results'}]
      end

    end

    render :text => to_render.to_json
    
  end

  def autocomplete2
    to_render = []
    final_list=[]
    list_terms = params[:term].split(/\s+/)
    
    final_list= Protein.find(:all,
                             :conditions => ["up_ac ~ ?", list_terms[0]])
    to_render = final_list.map{|e| {:id => e.id, :label => "#{e.up_ac}"}}.first(10)
    
    render :text => to_render.to_json
  end

   def render_protein_list_as_text(l)
    return ['UniProt AC', 'UniProt ID', 'First part UniProt ID', 'UniProt status', 'Organism', 'Gene names', 'Description', 'Number of isoforms',
            'Max number of cysteines', 'Predicted to be palmitoylated', 'Predicted to be palmitoylated in cytosolic domains',
            'Protein has hits?', 'Number of palmitoyl-proteome studies', 'Only in internal studies', 'Number of palmitoyl-proteome studies where the protein appears in a high confidence hit list', 'Number of targeted studies', 'Technique categories', 'Number of sites', 'Potential false positive'].join("\t") + "\n" +
        l.map{|p|
      hits = p.hits;
       studies = hits.map{|h| h.study}.uniq.select{|s| lab_user? or s.hidden == false};
       large_scale_studies = studies.select{|s| s.large_scale};

       hidden_studies=  hits.map{|h| h.study}.uniq.select{|s| s.hidden == true}.uniq
       hidden_large_scale_studies = hidden_studies.select{|s| s.large_scale};

      [p.up_ac, p.up_id, p.up_id.split("_")[0], ((p.trembl == true) ? 'Unreviewed' : 'Reviewed'), ((p.organism) ? p.organism.name : 'NA'),
       p.ref_proteins.select{|r| r.source_type_id == 1}.map{|r| r.value}.join(", "),  p.description, p.isoforms.select{|i| i.latest_version}.size,
       p.nber_cys_max, ((p.has_hc_pred) ? 'Yes' : 'No'), ((p.has_hc_pred_valid) ? 'Yes' : 'No'),
       ((p.has_hits == true) ? 'Yes' : 'No'),
       large_scale_studies.size.to_s + " of " +  @h_nber_studies_by_organism[p.organism_id].to_s,
       (large_scale_studies.size == 0) ? 'NA' : ((large_scale_studies.size == hidden_large_scale_studies.size) ? 'Yes' : 'No'),
       @hit_lists_by_protein[p.id].keys.compact.map{|hl_id| @h_hit_lists[hl_id]}.select{|hl| hl.confidence_level and hl.confidence_level.tag == 'HC'}.map{|hl| hl.study_id}.uniq.size,
       studies.reject{|s| s.large_scale}.size.to_s,
       large_scale_studies.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.map{|t| t.name}.sort.join(", "),
       hits.map{|h| h.sites}.flatten.map{|s| {:pos => s.pos, :isoform => s.hit.isoform}}.uniq.size.to_s,
       ( p.fp_chem == true or p.fp_label == true or p.fp_go == true) ? 'FP' : '-'
      ].join("\t")}.join("\n")

  end


  def compute_stats
      
    organism_ids = @proteins.map{|p| p.organism_id}.uniq  if @proteins
    organism_ids = @orthologue_proteins.map{|p| p.organism_id}.uniq  if @orthologue_proteins
    organism_ids.push(@protein.organism_id) if @protein
    @h_nber_studies_by_organism={}
    if organism_ids
      organisms = Organism.find(organism_ids)
      organisms.each do |o|
        @h_nber_studies_by_organism[o.id]=o.studies.select{|s| s.large_scale==true and (lab_user? or s.hidden == false)}.size #.map{|s| s.id}.join(",") # and (lab_user? or s.hidden == false)}.map{|s| s.id}.join(",") #.size
      end
    end
  end

  def compute_proteins_satellite_data
 
    @h_organisms = {}
    Organism.all.map{|o| @h_organisms[o.id]=o}

    @h_studies = {}
    Study.all.map{|s| @h_studies[s.id]=s}

    @nber_isoforms = {}
    @hits_by_protein = {}
    @hit_lists_by_protein = {}
    @sites_by_protein = {}
    @nber_sites_by_protein = {}

    @proteins.map{|p| @nber_isoforms[p.id]=0; @hits_by_protein[p.id]=[]; @sites_by_protein[p.id]=[]; @nber_sites_by_protein[p.id]=0}
    h_isoforms={}
    Isoform.find(:all, :conditions => {:latest_version => true, :protein_id => @proteins.map{|p| p.id}}).map{|i| @nber_isoforms[i.protein_id]+=1; h_isoforms[i.id]=i}


    h_hits={}
    hits = Hit.find(:all, :conditions => {:protein_id => @proteins.map{|p| p.id}})
    hits.select{|h| lab_user? or @h_studies[h.study_id].hidden == false}.map{|h| 
      @hits_by_protein[h.protein_id].push(h); 
      h_hits[h.id]=h
    }
    hit_lists = (hits and hits.size > 0) ? HitList.find(hits.map{|h| h.hit_list_id}.compact.uniq) : []
    @h_hit_lists = {}
    hit_lists.map{|hl| @h_hit_lists[hl.id]= hl}
    
    @hits_by_protein.each_key do |pid|
      @hit_lists_by_protein[pid] = {}
      @hits_by_protein[pid].each do |h|
        @hit_lists_by_protein[pid][h.hit_list_id]=1
      end
    end

    @sites = Site.find(:all, :conditions => {:hit_id => hits.map{|h| h.id}})
    @h_hits = h_hits
    @sites.map{|s| @sites_by_protein[h_hits[s.hit_id].protein_id].push(s) if  h_hits[s.hit_id]}
#    @test = @sites.select{|s| !h_hits[s.hit_id] or !h_hits[s.hit_id].protein_id or !@sites_by_protein[h_hits[s.hit_id].protein_id]}.map{|s| [s.hit_id, h_hits[s.hit_id]]}
    @sites_by_protein.each_key do |pid|
      @nber_sites_by_protein[pid] = @sites_by_protein[pid].flatten.map{|s| {:pos => s.pos, :isoform => h_hits[s.hit_id].isoform_id}}.uniq.size
    end

  end
  
  def batch_search

    @all_palm_proteins = Protein.find(:all, :conditions => {:has_hits => true})
    # @all_proteins_count = Protein.count
    
    @id_list = params[:file].read().split(/[\n\r]+/).map{|e| e.split(/[\t,]/).first}

    @proteins = Protein.find_all_by_up_id(@id_list) 
    @proteins += Protein.find_all_by_up_ac(@id_list)

    @proteins += Protein.find(:all, 
                              :joins => 'join ref_proteins on (ref_proteins.protein_id = proteins.id)', 
                              :conditions => ["lower(value) in (?)", @id_list.map{|e| e.downcase}]# { :ref_proteins => {:value => @id_list}}
                              )    

#    @h_studies = {}
#    Study.all.map{|s| @h_studies[s.id]=s}

    if session[:search_db] == 'palm'
      @proteins.select!{|e| (admin? or lab_user?) ? e.has_hits == true : e.has_hits_public == true}
    elsif session[:search_db] == 'meth' 

      @proteins.select!{|e| (admin? or lab_user?) ? e.has_hits == true : e.has_hits_public == true and 
        (((lab_user? and e.nber_technique_categories_labuser > 1) or e.nber_technique_categories_public > 1) or e.has_hits_targeted == true)
      }
      #     hits = Hit.find(:all, :conditions => {:protein_id => @proteins.map{|p| p.id}})
      #     h_hits_by_pid= {}
      #     hits.map{|h| h_hits_by_pid[h.protein_id]||=[]; h_hits_by_pid[h.protein_id].push(h)}
      
      #     @proteins.select!{|e| 
      #       studies = h_hits_by_pid[e.id].select{|h| 
      #         s= @h_studies[h.study_id]
      #         (lab_user? or s.hidden == false)}.map{|h| @h_studies[h.study_id]
      #       }.uniq
      #       ((admin? or lab_user?) ? e.has_hits == true : e.has_hits_public == true) and 
      #       studies.select{|s| s.large_scale}.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size
      #     }
    elsif session[:search_db] == 'meth2'
      @proteins.select!{|e| e.validated_dataset}
    elsif session[:search_db] == 'pred'
      @proteins.select!{|e| e.has_hc_pred == true}
    end
      
    @proteins.select!{|e| e.organism_id == session[:organism_id]} if session[:organism_id]
    @proteins ||= []
    @proteins.uniq!
    @count_proteins = @proteins.size

    #### find identifier not found
    ref_proteins = RefProtein.find_all_by_protein_id(@proteins.map{|p| p.id})
    h_ref_proteins = {}
    ref_proteins.map{|e| h_ref_proteins[e.value]=e.protein_id}
    @proteins.map{|p| h_ref_proteins[p.up_ac]=p.id; h_ref_proteins[p.up_id]=p.id}
 
    @not_found = @id_list.select{|val| !h_ref_proteins[val]}

    compute_stats()  
    compute_proteins_satellite_data()

#     respond_to do |format|
#      format.html { render :index, :layout => 'home_page' } # index.html.erb          
#      format.text { send_data render_protein_list_as_text(@proteins),
#        :filename => 'query_result.txt'
#      }
#      format.json { render json: @proteins }
#      end
    render :index, :layout => 'home_page'
  
  end

  def search

    conditions = [""]
    cond_parts = []
    
    search_db_query = ''
    if session[:search_db] == 'palm' or session[:search_db] == 'meth'  #or session[:search_db] == 'pred'
      search_db_query = ' and has_hits = ?'
      #  search_db_query = (admin? or lab_user?) ? ' and has_hits = ?' : ' and has_hits_public = ?'
      # elsif session[:search_db] == 'pred'
      #   search_db_query = ' and has_hc_pred = ?'
    end
#    search_db_query += ((lab_user?) ? ' and nber_technique_categories_labuser' : ' and nber_technique_categories_public') + "  > 1" if session[:search_db] == 'meth'
    search_db = (session[:search_db] == 'palm' or session[:search_db] == 'meth') ? true : nil
    
    h_status = {
      'Experimental evidence' => 0,
      'By similarity' => 1,
      'Probable' => 2,
      'Potential' => 3
    }
    
    res = []

    count = 0

    h_subcell = {}
    if params[:term].match(/^Subcellular:(.+?) \(>\= (.+?)\)( only)?/)
      h_subcell_names={}
      SubcellularLocation.all.each do |s|
        h_subcell_names[s.id]=s.name
      end
      Protein.find(:all, :select => 'protein_id, subcellular_location_id', :joins => 'join proteins_subcellular_locations on (proteins.id = protein_id)').each do |e|
        h_subcell[e['protein_id'].to_i]||=[]
        h_subcell[e['protein_id'].to_i].push(h_subcell_names[e['subcellular_location_id'].to_i])
      end
    end

    terms = params[:term].split(' and ')

    all = false

    h_other_conditions = {}
    
    tags_without_input = ['All', 'Reviewed']

    terms.map{|e| e.strip}.each do |term| 

      tmp_res = []
      if term == 'All'
        all = true
      elsif term == 'Reviewed'
        h_other_conditions[:trembl] = false
      elsif m = term.match(/^Gene:(.+)/)
        gene_names =  RefProtein.find(:all, :conditions => {:value => m[1], :source_type_id => 1})
       # if gene_names
        tmp_res = gene_names.map{|gn| gn.protein_id}
       # elsif
      elsif m = term.match(/^GO:(.+)/)
        go_term =  GoTerm.find(:first, :conditions => {:name => m[1]})        
        if go_term
          go_term =  GoTerm.find(:first, :conditions => {:name => m[1]})
          tmp_res = go_term.protein_go_associations.map{|gta| gta.protein_id}
        else
          go_terms =  GoTerm.find(:all, :conditions => ["lower(name) ~ ?", m[1].downcase])
          tmp_res = go_terms.map{|gt| gt.protein_go_associations.map{|gta| gta.protein_id}}.flatten.uniq
        end

      elsif m = term.match(/^Subcellular:(.+?) \(>\= (.+?)\)( only)?/)# or  m = params[:term].strip.match(/^Subcellular:(.+)/)
        
        subcells = SubcellularLocation.find(:all, :conditions => ["name ~ E? and status <= ?", "^#{m[1]}$", h_status[m[2]]])
        #anti_subcells = SubcellularLocation.find(:all, :conditions => ["name !~ E? and status <=?", "#{m[1]}$", h_status[m[2]]]) if m[3]

        tmp_res = subcells.map{|subcell| subcell.proteins}.flatten.uniq if subcells
        if m[3]
          tmp_res.select!{|p| #p_subcells = p.subcellular_locations; 
            h_subcell[p.id] and h_subcell[p.id].select{|s_name| s_name.match(/^#{m[1]}$/)}.size == h_subcell[p.id].size}
        end
        tmp_res.map!{|p| p.id}
#        subcell = SubcellularLocation.find(:first, :conditions => ["name ~ E? and status <= ?", "^#{m[1]}$", h_status[m[2]]])                                           
#        tmp_res = subcell.proteins.map{|p| p.id} if subcell   
      elsif m = term.match(/^Motif:(.+)/)
        isoforms = Isoform.find(:all, :select => 'protein_id', :conditions => ['seq ~ E? and latest_version = true', m[1]])
        tmp_res = isoforms.map{|e| e.protein_id}.uniq
      else      
        subterms = term.downcase.split(/\s*,\s*/).uniq

        if subterms.size > 0
          subterm = subterms.shift
          tmp_res = Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , subterm.downcase, search_db].compact).map{|e| e.protein_ids.split(',').map{|e| e.to_i}}.flatten.uniq
          
          #.map{|e| e.protein_ids.split(',', -1)}.flatten.uniq!
          #   logger.debug(res)
          
          subterms.each do |subterm|
            tmp_res &= Word.find(:all, :conditions => ["lower(value) ~ ? #{search_db_query}" , subterm.downcase, search_db].compact).map{|e| e.protein_ids.split(',').map{|e| e.to_i}}.flatten.uniq || []
          end
        end
      end

      if !tags_without_input.include?(term)
        logger.debug("term: #{term} : " + tmp_res.size.to_s)
        logger.debug(tmp_res.first(5).to_json)
        if count == 0 
          res = tmp_res
        else
          res &= tmp_res
        end
        logger.debug(res.first(5).to_json)
        logger.debug(res.size)
        count+=1
      end
    end
    #logger.debug(res)

    all = true if h_other_conditions[:trembl] == false and res.size == 0 and count == 0 ##count == 0 => there was no expression / tag to search upper (only tags without input) 
    query_parts = []
    query_parts.push("id in (?)") if all == false 
    vals = []
    vals.push(res) if (all == false) 
    if h_other_conditions[:trembl]
      query_parts.push("trembl is #{h_other_conditions[:trembl]}")      
      vals.push(h_other_conditions[:trembl])
    end
    
    if (session[:search_db] == 'palm' or session[:search_db] == 'meth')
      if admin? or lab_user?
        query_parts.push("has_hits is true") 
      else
        query_parts.push("has_hits_public is true") 
      end
    elsif session[:search_db] == 'pred'                                                                                                                                                                              
      query_parts.push("has_hc_pred is true")                                                                             
    end

    if session[:search_db]=='meth'
      if admin? or lab_user?
        query_parts.push("(nber_technique_categories_labuser > 1 or has_hits_targeted is true)")
      else
        query_parts.push("(nber_technique_categories_public > 1 or has_hits_targeted is true)")
      end
    end
    if session[:search_db] == 'meth2'
      query_parts.push("validated_dataset is true")
    end
    if session[:organism_id]                                                                                                                                                                                         
      query_parts.push("organism_id = #{session[:organism_id]}")                                                                                                           
    end  
    logger.debug(vals.to_json)
    #   h = (all == false) ? {:id => res} : {}
    #   h.merge!(h_other_conditions)
    #   if (session[:search_db] == 'palm')
    #     if admin? or lab_user?
    #       h[:has_hits] = true
    #     else
    #       h[:has_hits_public] = true
    #       
    #     end
    #   elsif session[:search_db] == 'pred'
    #      h[:has_hc_pred] = true
    #   end
    #   if session[:organism_id]
    #     h[:organism_id] = session[:organism_id]
    #   end
    
#    logger.debug(h.to_json)
    query = [query_parts.join(" and ")] + vals
    @count_proteins =  Protein.count(:conditions => query)
    @proteins = Protein.find(:all, :conditions => query, :limit => ((params[:format] == 'text') ? nil : 1000))
    
    compute_proteins_satellite_data()
    
    #   end
    
    ### count large scale studies by organism

    compute_stats()
    
     respond_to do |format|
      format.text {
   #['UniProt AC', 'UniProt ID', 'First part UniProt ID', 'UniProt status', 'Organism', 'Gene names', 'Description', 'Number of isoforms', 
 #                   'Max number of cysteines', 'Predicted to be palmitoylated', 'Predicted to be palmitoylated + validation',
 #                   'Protein has hits?', 'Number of hits in palmitome studies', 'Number of hits in targeted studies', 'Number of technique categories', 'Number of sites'].join("\t") + "\n" + @proteins.map{|p|
 #        # p = h_proteins[id];
 #         hits = p.hits;
 #         studies = hits.map{|h| h.study}.uniq;
 #         large_scale_studies = studies.select{|s| s.large_scale};
 #         [p.up_ac, p.up_id, p.up_id.split("_")[0], ((p.trembl == true) ? 'Unreviewed' : 'Reviewed'), ((p.organism) ? p.organism.name : 'NA'),
 #          p.ref_proteins.select{|r| r.source_type_id == 1}.map{|r| r.value}.join(", "),  p.description, p.isoforms.select{|i| i.latest_version}.size,
 #          p.nber_cys_max, ((p.has_hc_pred) ? 'Yes' : 'No'), ((p.has_hc_pred_valid) ? 'Yes' : 'No'),
 #          ((p.has_hits == true) ? 'Yes' : 'No'),
 #          large_scale_studies.size.to_s + " of " +  @h_nber_studies_by_organism[p.organism_id].to_s,
 #          studies.reject{|s| s.large_scale}.size.to_s,
 #          large_scale_studies.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size,
 #          hits.map{|h| h.sites}.flatten.map{|s| {:pos => s.pos, :isoform => s.hit.isoform}}.uniq.size.to_s
 #         ].join("\t")}.join("\n")
      send_data  render_protein_list_as_text(@proteins), :filename => 'query_result.txt'
      }
      format.html{         
        render :partial => 'index'
      }
      #      format.json { render json: @proteins }                                                                                                                                                                      
    end
    
    
  end
  
  def search_old
    
    #   threshold = 6


   conditions = [""]
   cond_parts = []
   subterms = params[:term].downcase.split(/[^\w\d]+/).uniq

 #  subterms.each do |subterm|
 #    cond_parts.push('value ~ ?')
 #    conditions.push(subterm)
 #  end
 #  conditions[0]= cond_parts.join(" OR ")

   palm_protein_ids = Protein.find(:all, :conditions => {:has_hits => true}).map{|e| e.id}

   counts = []
   subterms.each_index do |i|
     subterm = subterms[i]
     count = RefPalm.count(:all, :conditions => ['lower(value) ~ ?' , subterm])
     counts.push([subterm, count])
     break if count ==0
   end
   
   counts.sort!{|a,b| a[1] <=> b[1]}
   nber_proteins = 0
   protein_ids = []
   
#   if counts.first[1] < 1000
     
   log = ''
   if counts.first[1] >0
     seedterm = counts.first[0]
       ref_proteins = RefPalm.find(:all, :conditions => ['lower(value) ~ ?' , seedterm])
     protein_ids = ref_proteins.map{|e| e.protein_id}.uniq
     log += protein_ids.join(',')
     
     (1 .. counts.size-1).to_a.each do |i|
       if  protein_ids.size < 100
         ref_proteins = RefPalm.find(:all, :conditions => ['lower(value) ~ ? and protein_id in (?)' , counts[i][0], protein_ids])
         protein_ids= ref_proteins.map{|e| e.protein_id}.uniq
         #       ref_proteins.map{|e| proteins[e.protein_id]=nil}
       else
         ref_proteins2 = RefPalm.find(:all, :conditions => ['lower(value) ~ ?' , counts[i][0]])
         protein_ids2 = ref_proteins2.map{|e| e.protein_id}.uniq
         #         log += protein_ids.join(',') + 'bla'
         protein_ids = protein_ids & protein_ids2
         #         log += protein_ids.join(',')
       end
     end
     #else

   #end
                                   

#   h_proteins = {}
     #   ref_proteins.map{|e| h_proteins[e.protein_id]=nil}
    # nber_proteins = protein_ids.size
     
    # if nber_proteins > threshold
    #   protein_ids = protein_ids.first(threshold)
    # end
     
   end

    @proteins = Protein.find(protein_ids)

#   to_render =  protein_ids.map{|p| {:id => p.up_ac, :label => p.up_ac}}
#   label = ''
#   label = 'No results' if nber_proteins == 0
#   label = (nber_proteins-threshold).to_s + ' more' if nber_proteins >threshold
#   to_render.push({:id => nil, :label => label})  if label  != ''
#   to_render.push({:id => nil, :label => log})
   render :partial => 'index'
#   respond_to do |format|
#     format.json { render :json => result.to_json }
#    end

 end


  def download
    
    list_ids = params[:id_list].split(",").map{|e| e.split("_")[1].to_i}
    @proteins = Protein.find(list_ids)
    compute_stats()
    h_proteins = {}
    @proteins.map{|p| h_proteins[p.id]=p}
    compute_proteins_satellite_data()

    respond_to do |format|
      format.text {render text: 
        render_protein_list_as_text(list_ids.map{|id| h_proteins[id]})
 #       ['UniProt AC', 'UniProt ID', 'First part UniProt ID', 'UniProt status', 'Organism', 'Gene names', 'Description', 'Number of isoforms', 
 #        'Max number of cysteines', 'Predicted to be palmitoylated', 'Predicted to be palmitoylated + validation',
 #        'Protein has hits?', 'Number of hits in palmitome studies', 'Number of hits in targeted studies', 'Number of technique categories', 'Number of sites'].join("\t") + "\n" + list_ids.map{|id| 
 #         p = h_proteins[id];
 #         hits = p.hits;
 #         studies = hits.map{|h| h.study}.uniq;
 #         large_scale_studies = studies.select{|s| s.large_scale};
 #         [p.up_ac, p.up_id, p.up_id.split("_")[0], ((p.trembl == true) ? 'Unreviewed' : 'Reviewed'), ((p.organism) ? p.organism.name : 'NA'),  
 #          p.ref_proteins.select{|r| r.source_type_id == 1}.map{|r| r.value}.join(", "),  p.description, p.isoforms.select{|i| i.latest_version}.size,
 #          p.nber_cys_max, ((p.has_hc_pred) ? 'Yes' : 'No'), ((p.has_hc_pred_valid) ? 'Yes' : 'No'),
 #          ((p.has_hits == true) ? 'Yes' : 'No'),
 #          large_scale_studies.size.to_s + " of " +  @h_nber_studies_by_organism[p.organism_id].to_s,
 #          studies.reject{|s| s.large_scale}.size.to_s,
 #          large_scale_studies.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size,
 #          hits.map{|h| h.sites}.flatten.map{|s| {:pos => s.pos, :isoform => s.hit.isoform}}.uniq.size.to_s
 #         ].join("\t")}.join("\n")
      }
      #      format.json { render json: @proteins }
    end
    
  end

  # GET /proteins
  # GET /proteins.json
  def index
    
    #   h_organisms = {}
    #   Organism.all.each do |o|
    #     h_organisms[o.up_tag]=o
    #   end
    
    #    @proteins = Protein.find(:all, :conditions => {:has_hits => true, :organism_id => h_organisms[params[:organism_tag]].id})
    #  @all_proteins_count = Protein.count
    session[:search_db]=(params[:search_db]) ? params[:search_db] : nil 
    session[:organism_id]=(params[:organism_id] and  params[:organism_id]!='') ? params[:organism_id].to_i : nil

    @all_palm_proteins = Protein.find(:all, :conditions => {:has_hits => true})
    #    @proteins.select!{|e| e.organism_id ==1 }
    
    # organism_ids = @all_proteins.map{|p| p.organism_id}.uniq
    organisms = Organism.all #find(organism_ids)
    @h_nber_studies_by_organism={}
    organisms.each do |o|
      @h_nber_studies_by_organism[o.id]=o.studies.select{|s| s.large_scale==true and (lab_user? or s.hidden == false)}.size #.map{|s| s.id}.join(",")
    end
    
    respond_to do |format|
      format.html { render :layout => 'home_page' } # index.html.erb
      format.text {   
#[
#                                'UniProt AC', 'UniProt ID', 'UniProt status', 'Organism', 'Description', 'Isoforms', 
#                                'Max number of cysteines', 'Predicted to be palmitoylated', 'Predicted to be palmitoylated + validation',
#                                '# of palmitome studies', '# of targeted studies', '# of distinct techniques', '# of known sites'  
#                               ].join("\t") + "\n" + @all_palm_proteins.map{|p| 
#          [p.up_ac, p.up_id, ((p.trembl == true) ? 'Unreviewed' : 'Reviewed'), ((p.organism) ? p.organism.name : ''), "\"#{p.description}\"", p.isoforms.select{|i| i.latest_version}.size, 
#           p.nber_cys_max, ((p.has_hc_pred) ? 'Yes' : 'No'), ((p.has_hc_pred_valid) ? 'Yes' : 'No'), 
#           ((p.has_hits == true) ? 'Yes' : 'No'),
#           p.hits.map{|h| h.study}.select{|s| #s.organism_id == p.organism_id and 
#             s.large_scale and (lab_user? or s.hidden == false)}.uniq.size.to_s + "/" +  @h_nber_studies_by_organism[p.organism_id].to_s,
#           studies.reject{|s| s.large_scale}.size.to_s,
#           large_scale_studies.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size,
#           p.hits.map{|h| h.sites}.flatten.map{|s| {:pos => s.pos, :isoform => s.hit.isoform}}.uniq.size.to_s
#          ].join(", ")
#        }.join("\n")
        send_data render_protein_list_as_text(@all_palm_proteins),
        :filename => 'query_result.txt'
      }
      format.json { render json: @all_palm_proteins }
    end
  end
  

  def view_ali
    
    protein = Protein.find(params[:id])
    isoforms = protein.isoforms.select{|i| i.latest_version}

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'isoform_ma'

    @h_seq = []
 
    tmp_h_seq={}
   
    if isoforms.size > 1

      main_iso = isoforms.select{|e| e.main == true}.first.isoform
      h_isoforms = {}
      isoforms.map{|e| h_isoforms[e.isoform] = e}
      
      file = dir + "#{protein.up_ac}.clw"
  
      File.open(file, 'r') do |f|
        
        isoforms.each do |isoform| ## initialization
          tmp_h_seq[isoform.isoform]=''
        end
        i = 0
        while (!f.eof? and l = f.readline)        
          if m = l.match(/^([\w\-]+)\s+([\w\-]+)/) and i > 2
            t = m[1].split('-')
            iso = (t.size == 2) ? t[1] : main_iso
            tmp_h_seq[iso.to_i] += m[2]
          end
          i+=1
        end
        
      end
    else
      tmp_h_seq[1]=isoforms.first.seq
    end
    

    tmp_h_seq.each_key do |iso|
      (0 .. tmp_h_seq[iso].size-1).each do |i|
        chunk = (i/100).to_i
        @h_seq[chunk]||={}
        @h_seq[chunk][iso]||=''
        @h_seq[chunk][iso]+=tmp_h_seq[iso][i]
      end
    end


    if params[:partial]=='1'
      render :layout => false
    else
      render :layout => 'ali'
    end
  end

  def view_ali_ortho

    protein = Protein.find(params[:id])
    @h_orthologues={}
    @orthologues = Orthologue.find(:all, :conditions => {:protein_id2 => protein.id}).map{|e| @h_orthologues[e.protein_id1]=e; e} | Orthologue.find(:all, :conditions => {:protein_id1 => protein.id}).map{|e| @h_orthologues[e.protein_id2]=e; e}
    @orthologue_proteins = Protein.find(@h_orthologues.keys)
    lead = protein.isoforms.select{|i| i.latest_version and i.main== true }.first
    isoforms = @orthologue_proteins.map{|p| p.isoforms.select{|e| e.latest_version and e.main == true}}.flatten.uniq | [lead]
    @lead_identifier = protein.up_ac + ((lead.main == true) ? '' : "-#{lead.isoform}")
    #    isoforms = protein.isoforms.select{|i| i.latest_version}

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'orthologue_ma'

    @h_seq = []

    tmp_h_seq={}

    if isoforms.size > 1

      #      main_iso = isoforms.select{|e| e.main == true}.first.isoform
      h_isoforms = {}
      isoforms.map{|e| h_isoforms[e.isoform] = e}

      file = dir + "#{protein.up_ac}.clw"

      if File.exists?(file)
        File.open(file, 'r') do |f|
          
          isoforms.each do |isoform| ## initialization                                              
            identifier = isoform.protein.up_ac + ((isoform.main == true) ? '' : "-#{isoform.isoform}")
            tmp_h_seq[identifier]=''
          end
          i = 0
          while (!f.eof? and l = f.readline)
            if m = l.match(/^([\w\-]+)\s+([\w\-]+)/) and i > 2
              # t = m[1].split('-')
              # iso = (t.size == 2) ? t[1] : main_iso
              tmp_h_seq[m[1]] += m[2]
            end
            i+=1
          end
        end
      end
      #    else
      #      tmp_h_seq[]=isoforms.first.seq
   


      tmp_h_seq.each_key do |iso|
        (0 .. tmp_h_seq[iso].size-1).each do |i|
          chunk = (i/100).to_i
          @h_seq[chunk]||={}
          @h_seq[chunk][iso]||=''
          @h_seq[chunk][iso]+=tmp_h_seq[iso][i]
        end
      end
    end

    if params[:partial]=='1'
      render :layout => false
    else
      render :layout => 'ali'
    end
  end


  # GET /proteins/1
  # GET /proteins/1.json
  def show

    @h_uniprot_statuses = {}
    UniprotStatus.all.map{|us| @h_uniprot_statuses[us.id] = us.name}

    @protein = Protein.find(params[:id])

    ### get source types
    @h_source_types ={}
    @h_ref_proteins={}
    SourceType.all.map{|st| @h_source_types[st.id]=st;  @h_ref_proteins[st.id]=[]}

    ### get references
    @protein.ref_proteins.map{|e| @h_ref_proteins[e.source_type_id].push(e)} 
    @h_ref_proteins.keys.map{|k| @h_ref_proteins.delete(k) if @h_ref_proteins[k].size == 0}
    
    
    ### get subcellular locations
    h_subcellular_locations = {}
    SubcellularLocation.all.each do |sl|
      h_subcellular_locations[sl.id] = sl
    end

    ### topodoms + disulfides
    disulfides = Feature.find(:all, :conditions => {:protein_id => @protein.id, :feature_type_id => 6}).map{|e| [e.start, e.stop]}.flatten.uniq
    topo_doms = Feature.find(:all, :conditions => {:protein_id => @protein.id, :feature_type_id => [1,2]}, :order => 'start')
    @topo_doms = topo_doms
#    subcell_loc = SubcellularLocation.find(:all, :select => "subcellular_location_id", :joins => "join proteins_subcellular_locations on (subcellular_locations.id = subcellular_location_id)", :conditions => {:protein_id => @protein.id}).map{|e| e.subcellular_location_id.to_i}.uniq

    @subcell =  @protein.subcellular_locations#.map{|sl| sl.name}
    subcell_loc = @subcell.map{|sl| sl.id}

    @extracellular_prot = 0    
    extracell_subloc = subcell_loc.reject{|sl_id| ['Extracellular', 'Lumenal', 'Endoplasmic reticulum lumen'].include?(h_subcellular_locations[sl_id].name)}
    cytoplasm_subloc = subcell_loc.reject{|sl_id| ['Cytoplasmic', 'Nucleus'].include?(h_subcellular_locations[sl_id].name)}

    if extracell_subloc.size == 0
      @extracellular_prot=1
    elsif extracell_subloc.size < subcell_loc.size
      @extracellular_prot=2
    end
    @cytoplasmic_prot = 0
    if cytoplasm_subloc.size == 0
      @cytoplasmic_prot=1
    elsif cytoplasm_subloc.size < subcell_loc.size
      @cytoplasmic_prot=2
    end

  
    ### go terms
    @h_go_term_by_term_type = {}
    @protein.protein_go_associations.select{|e| e.parent == false}.map{|e| 
      @h_go_term_by_term_type[e.go_term.term_type] ||= []
      @h_go_term_by_term_type[e.go_term.term_type].push([e.id, e.go_term.name])
    }

    @hits = @protein.hits
    @hits.reject!{|h| h.study.hidden == true} if !lab_user? and !admin?

    @studies = @hits.map{|e| e.study}.uniq.sort{|a, b| a.id <=> b.id}
   
    h_studies_by_pmid = {}
    @studies.map{|s| 
      h_studies_by_pmid[s.pmid]||=[];
      h_studies_by_pmid[s.pmid].push(s);
    }

    @h_studies={}
    @studies.each_index do |s_i|
      @h_studies[@studies[s_i].id]=s_i
    end

    @articles = Article.find_all_by_pmid(@studies.select{|e| e.pmid}.map{|e| e.pmid}.uniq)

    @h_articles={}
    @articles.each_index do |a_i|
      @h_articles[@articles[a_i].pmid]=a_i
    end


    @studies_by_article = []
    @articles.each_index do |i|
      @studies_by_article.push(h_studies_by_pmid[@articles[i].pmid])
    end
    @isoforms = @protein.isoforms.select{|e| e.latest_version == true}
    #hit_lists = @hits.map{|e| e.hit_list}.select{|e| e}.uniq
    #    @large_scale_hit_lists = hit_lists.select{|e| e.study.large_scale == true}
    # large_scale_studies = studies.select{|e| e.large_scale == true}
    # site_studies = studies.select{|e| e.large_scale == true}
 
    #### read multiple ali

    @h_pos_ali = {}
    @pos_ali = []
    @h_pred = {}
    @main_iso = ''
   
    @isoforms.each do |isoform|
      iso = isoform.isoform

      @main_iso = iso if isoform.main == true

      @h_pred[iso]={}
      @h_pos_ali[iso]={}
      
      isoform.predictions.each do |pred|
        ##compute position in ali
        pos_ali = 0
        cur_pos = 0
        gaps=0
        if isoform.iso_ma_mask
          isoform.iso_ma_mask.split(',').each do |mask_el|
            if mask_el[0] == ':'
              cur_pos += mask_el[1..-1].to_i 
            else
              gaps+= mask_el[1..-1].to_i
            end
            if cur_pos >= pred.pos
              pos_ali = pred.pos + gaps
              break
            end
          end
        else
          pos_ali = pred.pos
        end
        @h_pos_ali[iso][pos_ali]= pred.pos
        @pos_ali.push(pos_ali) if !@pos_ali.include?(pos_ali)
        @h_pred[iso][pred.pos]=[
                                pred,
                               # pred.cp_score,
                               # '',
                               # pred.cp_high_cutoff,
                               # pred.cp_medium_cutoff,
                               # pred.cp_low_cutoff,
                                (pred.cp_high_cutoff > 0) ? 'hc' : 
                                ((pred.cp_medium_cutoff > 0) ? 'mc' :
                                 ((pred.cp_low_cutoff > 0) ? 'lc' : '')),
                                
                                pos_ali,
                                pred.uniprot_ss,
                                pred.psipred_ss
                               # pred.hc_pred,
                               # pred.compatible_loc
                               ]
      

      end
      
    end
  
    @pos_ali.sort!
    
    @chunks = []
    (0 .. @pos_ali.size-1).each do |i|
      chunk = (i/14).to_i
      @chunks[chunk]||=[] #if i % 20 == 0
      @chunks[chunk].push(@pos_ali[i])
    end
        

    #    main_isoform = @isoforms.select{|i| i.main == true} 
    @debug = ''
    @h_data_by_ali_pos = {:disulfide => {}, :topology => {}}

    if topo_doms and topo_doms.size > 0
      i=0
      @h_pred[@main_iso].keys.sort.each do |pred_pos|
        ali_pos = @h_pred[@main_iso][pred_pos][2]
  
        @h_data_by_ali_pos[:disulfide][ali_pos]= (disulfides.include?(pred_pos)) ? 1 : 0

        while i < topo_doms.size and pred_pos > topo_doms[i].stop do
          i+=1
        end
        i-=1 if i == topo_doms.size
    #    @debug += "#{pred_pos} >= #{topo_doms[i].start} and #{pred_pos} <= #{topo_doms[i].stop} #{i}<br/>"
        if (pred_pos >= topo_doms[i].start and pred_pos <= topo_doms[i].stop and topo_doms[i].description.match(/^(Lumenal)|(Extracellular)/)) or @extracellular_prot == 1
          @h_data_by_ali_pos[:topology][ali_pos]= 1
        elsif pred_pos >= topo_doms[i].start and pred_pos <= topo_doms[i].stop and topo_doms[i].description.match(/^Helical/)
          @h_data_by_ali_pos[:topology][ali_pos]= 2
        elsif (pred_pos >= topo_doms[i].start and pred_pos <= topo_doms[i].stop and topo_doms[i].description.match(/^Cytoplasmic/)) 
          @h_data_by_ali_pos[:topology][ali_pos]= 3
        else
          @h_data_by_ali_pos[:topology][ali_pos]= 0
        end        
      end
    else
      @h_pred[@main_iso].keys.sort.each do |pred_pos|
        ali_pos = @h_pred[@main_iso][pred_pos][2]
        
        @h_data_by_ali_pos[:disulfide][ali_pos]= (disulfides.include?(pred_pos)) ? 1 : 0
        if @cytoplasmic_prot == 1 or (@cytoplasmic_prot == 2 and @extracellular_prot ==0)
          @h_data_by_ali_pos[:topology][ali_pos]= 3
        elsif  @extracellular_prot == 1 or (@extracellular_prot == 2 and @cytoplasmic_prot ==0)
          @h_data_by_ali_pos[:topology][ali_pos]= 1
        end
      end
    end
    
    @pat_reactions =  Reaction.find(:all, :conditions => {
                                      :is_a_pat => true,
                                      :protein_id => @protein.id})

    @h_pat_sites = {}
    @pat_reactions.each do |pr|
      if pr.site
        @h_pat_sites[pr.hit.protein_id]=1
      end
    end
    @apt_reactions = Reaction.find(:all, :conditions => {
                                      :is_a_pat => false,
                                      :protein_id => @protein.id
                                    })
    @h_apt_sites = {}
    @apt_reactions.each do |pr|
      if pr.site
        @h_apt_sites[pr.hit.protein_id]=1
      end
    end
    @h_pat_sites = {}
    @pat_reactions.each do |pr|
      if pr.site
        @h_pat_sites[pr.hit.protein_id]=1
      end
    end

    homologue_ids = []

#    @h_oma_pairs={:oma => {}, :gene_names=>{}}
#    oma_pairs = OmaPair.find(:all, :conditions => {:protein_id1 => @protein.id})
#    oma_pairs.each do |e|
#      if e.oma_relation_type_id != nil
#        @h_oma_pairs[:oma][e.protein_id2]=1
#      else
#        @h_oma_pairs[:blast][e.protein_id2]=1
#      end
#    end
#    orthologue_ids.push(oma_pairs.map{|e| e.protein_id2}) if oma_pairs.size > 0
#    oma_pairs = OmaPair.find(:all, :conditions => {:protein_id2 => @protein.id})
#    oma_pairs.each do |e|
#      if e.oma_relation_type_id != nil
#        @h_oma_pairs[:oma][e.protein_id1]=1
#      else
#        @h_oma_pairs[:blast][e.protein_id1]=1
#      end
#    end
#    orthologue_ids.push(oma_pairs.map{|e| e.protein_id1}) if oma_pairs.size > 0
#    orthologue_ids.flatten#.reject!{|e| e == nil}
#    logger.debug orthologue_ids.to_json

#    orthodb_groups = OrthodbAttr.find(:all, :conditions => {:protein_id => @protein.id}).map{|e| e.orthodb_group_id}.uniq
#    orthodb_attrs = OrthodbAttr.find(:all, :conditions => {:orthodb_group_id => orthodb_groups})
#    @h_orthodb_attrs = {}
#    orthodb_attrs.map{|e| @h_orthodb_attrs[e.protein_id]||=[]; @h_orthodb_attrs[e.protein_id].push(e)}
#    homologue_ids = orthodb_attrs.map{|e| e.protein_id}.reject{|e| e == @protein.id}.uniq
#    @homologues = (homologue_ids.size > 0) ? Protein.find(homologue_ids) : []

#    @h_best_orthologues = {}
#    Orthologue.find(:all, :conditions => {:protein_id2 => @protein.id}).map{|e| @h_best_orthologues[e.protein_id1]=1}
#    Orthologue.find(:all, :conditions => {:protein_id1 => @protein.id}).map{|e| @h_best_orthologues[e.protein_id2]=1}

    h_orthologue_proteins={}
    
    @h_orthologues={}
    @orthologues = Orthologue.find(:all, :conditions => {:protein_id2 => @protein.id}).map{|e| 
      @h_orthologues[e.protein_id1]=e; e
    } | Orthologue.find(:all, :conditions => {:protein_id1 => @protein.id}).map{|e| 
      @h_orthologues[e.protein_id2]=e; e
    }
    

    @orthologue_proteins = Protein.find(@h_orthologues.keys)

    @h_orthologue_proteins = {}    
    @h_studies_by_protein_id = {}
    @orthologue_proteins.map{|e| 
      @h_orthologue_proteins[e.id]=e
      @h_studies_by_protein_id[e.id]=e.hits.map{|h| h.study}.select{|s| !lab_user? and s.hidden == false}
    }
    
    @nber_orthologues_in_palmitomes = @h_orthologue_proteins.keys.select{|pid| @h_studies_by_protein_id[pid].select{|s| s.large_scale}.uniq.size > 0}.size
    @nber_orthologues_in_targeted_studies = @h_orthologue_proteins.keys.select{|pid| @h_studies_by_protein_id[pid].select{|s| s.large_scale == false}.uniq.size > 0}.size

    @h_phosphosite_types = {}
    @h_phosphosite_features = {}
    @h_isoforms_phosphosite={}
    
    PhosphositeType.all.map{|pft| 
      @h_phosphosite_types[pft.id] = pft; 
      @h_phosphosite_features[pft.id] = {}
    }
    PhosphositeFeature.find(:all, :joins => 'join isoforms on (isoform_id = isoforms.id)', :conditions => {:isoforms => {:protein_id => @protein.id}}).map{|pf| 
      @h_phosphosite_features[pf.phosphosite_type_id][pf.isoform_id]||=[]
      @h_phosphosite_features[pf.phosphosite_type_id][pf.isoform_id].push(pf)
      @h_isoforms_phosphosite[pf.isoform_id]=1
    }
    @h_phosphosite_types.keys.map{|e| @h_phosphosite_features.delete(e) if @h_phosphosite_features[e].keys.size == 0}

    

#    @nber_orthologues_in_palmitomes = PalmitomeEntry.find(:all, 
#                                                          :joins => 'join proteins on (proteins.id = protein_id) ', 
#                                                          :conditions => ["protein_id IN (?) and proteins.organism_id = palmitome_entries.organism_id and nber_palmitome_studies > 0",   @h_orthologue_proteins.keys]).select{|pe| pe.palmitome_study_ids.split(',').select{|sid|  !@h_studies[sid.to_i]}.size > 0 }.size
#    
    #    @h_best_orthologues={}
    #    h_done_species={}
    #    orthodb_attrs.select{|e| @protein.organism != e.protein.organism}.sort{|a, b| @h_orthodb_attrs[a.protein_id].size <=> @h_orthodb_attrs[b.protein_id].size}.each do |orthodb_attr|
    #      homologue = orthodb_attr.protein
    #      if !h_done_species[homologue.organism.id]
    #        @h_best_orthologues[homologue.id]=true
    #        h_done_species[homologue.organism.id]=@h_orthodb_attrs[homologue.id].size
    #      elsif h_done_species[homologue.organism.id]==@h_orthodb_attrs[homologue.id].size
    #        @h_best_orthologues[homologue.id]=true
    #      end
    #    end
    
    
    compute_stats()

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protein }
      format.pdf { render pdf: "report_#{@protein.up_id}.pdf"}
    end
  end

  # GET /proteins/new
  # GET /proteins/new.json
  def new
    @protein = Protein.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protein }
    end

  end

  # GET /proteins/1/edit
  def edit
    @protein = Protein.find(params[:id])
  end

  # POST /proteins
  # POST /proteins.json
  def create
    @protein = Protein.new(params[:protein])

    respond_to do |format|
      if @protein.save
        format.html { redirect_to @protein, notice: 'Protein was successfully created.' }
        format.json { render json: @protein, status: :created, location: @protein }
      else
        format.html { render action: "new" }
        format.json { render json: @protein.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /proteins/1
  # PUT /proteins/1.json
  def update
    @protein = Protein.find(params[:id])

    respond_to do |format|
      if @protein.update_attributes(params[:protein])
        format.html { redirect_to @protein, notice: 'Protein was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @protein.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proteins/1
  # DELETE /proteins/1.json
  def destroy
    @protein = Protein.find(params[:id])
    @protein.destroy

    respond_to do |format|
      format.html { redirect_to proteins_url }
      format.json { head :no_content }
    end
  end

end
