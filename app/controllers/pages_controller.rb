class PagesController < ApplicationController

#include ApplicationHelper
before_filter :authorize
#caches_action :palmitome_comparison

  def curation
  end

  def env_dataset_form

    respond_to do |format|
      format.html {}
    end

  end


  def background_composition
    
    @organism_ids =  (params[:organism_id]) ? params[:organism_id].split(/,/).map{|e| e.to_i} : nil
    @prot_type = params[:prot_type]
    @prot_topo  = params[:prot_topo]

    @output = params[:output] || 'compo'
    @prot_type ||= 'all'
    @prot_topo ||= 'all'
    @not_palm_prot = params[:not_palm_prot]
    @seq_list=[]


    @h_transmembrane_prots = {}

    if @prot_type !='all'
      transmembranes = Feature.find(:all, :conditions => {:feature_type_id => 1})
      h_cond = {:id => transmembranes.map{|e| e.protein_id}.uniq}
      h_cond[:organism_id]=@organism_ids if @organism_ids
      transmembrane_prots = Protein.find(:all, :conditions => h_cond)
      transmembrane_prots.map{|p| @h_transmembrane_prots[p.id]=1}
    end

    @h_topo_prots={}

    if @prot_topo !='all'

      h_cond = {:name => @prot_topo}
      h_cond[:proteins]={:organism_id => @organism_ids} if @organism_ids

      Topology.find(:all,
                    :select => 'protein_id',
                    :joins => 'join proteins_topologies on (proteins_topologies.topology_id = topologies.id) join proteins on (protein_id = proteins.id)',
                    :conditions => h_cond).map{|t| @h_topo_prots[t.protein_id.to_i]=1}
      # Protein.find(protein_ids).map{|p| @h_topo_prots[p.id] = p}
    end
    

    @l = {}
    @window = (params[:window]) ? params[:window].to_i : 25
    @aa = ['A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y', '-']
    
    isoforms = Isoform.find(:all, 
                            :joins => 'join proteins on (proteins.id = isoforms.protein_id)', 
                            :conditions => {:main => true, :latest_version => true, :proteins => {:organism_id => @organism_ids}})
    h_isoforms = {}
    isoforms.map{|i| h_isoforms[i.id]=i}
    predictions =Prediction.find(:all, 
                                 :joins => 'join isoforms on (isoforms.id = predictions.isoform_id) join proteins on (proteins.id = isoforms.protein_id)', 
                                 :conditions => {:isoforms =>{:main => true, :latest_version => true}, :proteins => {:organism_id => @organism_ids}}) 

    predictions = predictions.shuffle if params[:limit] #.first(params[:limit].to_i) if params[:limit]

    predictions.each do |pred|
        #        isoform = protein.isoforms.select{|i| i.main == true}.first
      isoform = h_isoforms[pred.isoform_id]
      protein = isoform.protein
      #        Prediction.find(:all, :conditions => {:isoform_id => isoform.id}).each do |pred|
      if (@prot_type == 'all' or (@prot_type == 'transmembrane' and @h_transmembrane_prots[isoform.protein_id]) or 
          (@prot_type == 'soluble' and !@h_transmembrane_prots[isoform.protein_id])) and 
          (@prot_topo =='all' or @h_topo_prots[isoform.protein_id]) and

          (!@not_palm_prot or (!protein.has_hits and !protein.has_hc_pred))
        
        start_pos = pred.pos - @window
        start_seq = (start_pos < 1) ? "-" * -(start_pos-1) : ''
        end_pos = pred.pos + @window
        end_seq = (end_pos > isoform.seq.size) ? "-" * (end_pos-isoform.seq.size) : ''
        start_pos = 1 if start_pos < 1
        end_pos = isoform.seq.size if end_pos > isoform.seq.size
        seq = start_seq + isoform.seq[start_pos-1 .. end_pos-1] + end_seq
        
        #seq = site.cys_env.seq                                                                                                                                                                                                      
        seq.split(//).each_index do |i|
          @l[seq[i]]||=[]
          @l[seq[i]][i]||=0
          @l[seq[i]][i]+=1
        end
        @seq_list.push({:protein => protein, :isoform => isoform, :pos => pred.pos, :seq => seq})
  
      end
      break if params[:limit] and @seq_list.size == params[:limit].to_i
 
    end
    
    respond_to do |format|
    #  if params[:partial]                                                                                                                                                                                                           
      format.html {}
      format.text {
        if @output == 'seq_list'
          render text: @seq_list.map{|e| [e[:protein].up_id, e[:protein].up_ac, e[:isoform].isoform, e[:pos], e[:seq]].join("\t")}.join("\n")
        elsif @output == 'fasta'
          render text: @seq_list.map{|e| ">#{e[:protein].up_id}|#{e[:protein].up_ac}|#{e[:isoform].isoform}|#{e[:pos]}\n#{e[:seq]}\n"}.join("")
        elsif @output == 'compo'
          render text: @l.to_json
        end
      }
      format.json { render json: @l.to_json }
    end

  end

  def site_composition

    @organism_ids = (params[:organism_id]) ? params[:organism_id].split(/,/).map{|e| e.to_i} : nil
    @prot_type = params[:prot_type]
    @prot_topo  = params[:prot_topo]
    @min_distance_helix = params[:min_distance_helix]
    @output = params[:output] || 'compo'
    @prot_topo ||= 'all'    
    @prot_type ||= 'all'

    h_transmembrane_prots={}

    if @prot_type !='all'
      
      transmembranes = Feature.find(:all, :conditions => {:feature_type_id => 1})
      h_cond = {:id => transmembranes.map{|e| e.protein_id}.uniq}
      h_cond[:organism_id]=@organism_ids if @organism_ids
      transmembrane_prots = Protein.find(:all, :conditions => h_cond)
      transmembrane_prots.map{|p| h_transmembrane_prots[p.id]=1}
      
    end
    
    h_topo_prots={}
    
    if @prot_topo != 'all'

      h_cond = {:name => @prot_topo}
      h_cond[:proteins]={:organism_id => @organism_ids} if @organism_ids
      Topology.find(:all,
                    :select => 'protein_id',
                    :joins => 'join proteins_topologies on (proteins_topologies.topology_id = topologies.id) join proteins on (protein_id = proteins.id)',
                    :conditions => h_cond).map{|t| h_topo_prots[t.protein_id.to_i]=1}
      #Protein.find(protein_ids).map{|p| h_topo_prots[p.id] = p}
    end
    

    @l = {}
    @seq_list=[]
    @list_proba=[]
    @window = (params[:window]) ? params[:window].to_i : 25
    (0 .. @window*2).to_a.map{|i| @list_proba[i]={}}
    @debug = ''
    h_taken={}
    @aa = ['A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y', '-']
    Site.all.each do |site|

      isoform = site.hit.isoform || site.hit.protein.isoforms.select{|i| i.main == true}.first
      protein = isoform.protein
      if (@prot_type == 'all' or (@prot_type == 'transmembrane' and h_transmembrane_prots[isoform.protein_id]) or 
          (@prot_type == 'soluble' and !h_transmembrane_prots[isoform.protein_id])) and
          (@prot_topo == 'all' or h_topo_prots[isoform.protein_id]) and          
          (!@organism_ids or @organism_ids.include?(protein.organism_id)) and !h_taken["#{isoform.id}:#{site.pos}"]
        start_pos = site.pos - @window
        start_seq = (start_pos < 1) ? "-" * -(start_pos-1) : ''
        end_pos = site.pos + @window
        end_seq = (end_pos > isoform.seq.size) ? "-" * (end_pos-isoform.seq.size) : ''
        start_pos = 1 if start_pos < 1
        end_pos = isoform.seq.size if end_pos > isoform.seq.size
        seq = start_seq + isoform.seq[start_pos-1 .. end_pos-1] + end_seq
        
        #seq = site.cys_env.seq
        seq.split(//).each_index do |i|
          @l[seq[i]]||=[]        
          @l[seq[i]][i]||=0
          @l[seq[i]][i]+=1
          if i > 0 and @output == 'proba'
            @list_proba[i][seq[i]]||={}
            @list_proba[i][seq[i]][seq[i-1]]||=0
            @list_proba[i][seq[i]][seq[i-1]]+=1
          end
          #          @seq_list
        end
        @seq_list.push({:protein => protein, :isoform => isoform, :pos => site.pos, :seq => seq})
        h_taken["#{isoform.id}:#{site.pos}"]=1 ## to discard duplicates because of multiple studies for a given site
        break if params[:limit] and h_taken.keys.size > params[:limit].to_i  
      end
        #      puts site.cys_env.to_json
    end
    
    respond_to do |format|
    #  if params[:partial]
      format.html {}
      format.text { 
        if @output == 'seq_list'
          render text: @seq_list.map{|e| [e[:protein].up_id, e[:protein].up_ac, e[:isoform].isoform, e[:pos], e[:seq]].join("\t")}.join("\n") 
        elsif @output == 'fasta'
          render text:  @seq_list.map{|e| ">#{e[:protein].up_id}|#{e[:protein].up_ac}|#{e[:isoform].isoform}|#{e[:pos]}\n#{e[:seq]}\n"}.join("")
        elsif @output == 'compo'
          render text: @l.to_json
        elsif @output == 'proba'
          render text: @list_proba.each_with_index.map{|e, i| ">position #{i}\n" + ["",  @aa].flatten.join("\t") + "\n" + e.keys.map{|k| [k, @aa.map{|k2| (e[k][k2]) ? e[k][k2] : '' }].flatten.join("\t")}.join("\n") }.join("\n\n")
        end
      }
      format.json { 
        if @output == 'compo'
          render json: @l.to_json 
        elsif  @output == 'proba'
          render text: @list_proba.to_json
        else
          render text: @seq_list.to_json
        end
      }
      
   #   else
   #     format.html # show.html.erb      
   #   end
    end


  end

  def stats_by_organism
    
    @topologies = []

    Organism.all.each do |o|
      h =JSON.parse(o.topo_json)
      h['all_cys'].keys.map{|k| @topologies.push(k) if !@topologies.include?(k)}
    end
    
  end

  def admin
  end

  def list_annotated_proteins
 
    params[:ref_organism_id]||=1
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    
    respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'palmitome_comparison'}
      else
        format.html # show.html.erb      
      end
    end
  
  end


  def palmitome_set_comparison_stats

    params[:ref_organism_id]||=1

    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @ref_organism = Organism.find(params[:ref_organism_id])

    @h_studies = {}
    @h_cell_types = {}
    @h_organisms = {}
    @h_hits={}
    @h_hit_lists = {}

    @h_confidence_levels={}
    ConfidenceLevel.all.map{|cl| @h_confidence_levels[cl.id]=cl}

    h_cond ={:large_scale => true}
    h_cond[:hidden]=false if !lab_user?

    @all_studies = Study.find(:all, :conditions => h_cond).select{|e| e.large_scale and e.cell_type and e.organism}

    @studies = []
    if session[:studies].size > 0
      h_tmp = h_cond
      h_tmp[:id]=session[:studies]
      @studies = Study.find(:all, :conditions => h_tmp)
    else
      @studies = Study.find(:all, :conditions => h_cond)
    end

    @studies= @studies.select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b|
      [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}

    @h_sel_studies = {}
    @studies.map{|s| @h_sel_studies[s.id]=1}

    hit_lists = HitList.find(:all, :conditions => {:study_id => @studies.map{|s| s.id}})
    hit_lists.each do |hl|
      @h_hit_lists[hl.id]=hl
    end

    if !params[:nber_studies] or params[:nber_studies].to_i > @studies.size
      params[:nber_studies] = (@studies.size * 0.7).to_i
    end

    @all_studies.map{|s|
      @h_cell_types[s.cell_type_id] = s.cell_type;
      @h_organisms[s.organism_id] = s.organism;
      @h_studies[s.organism_id]||={}
      @h_studies[s.organism_id][s.cell_type_id]||=[]
      @h_studies[s.organism_id][s.cell_type_id].push(s)
    }


  end

  def compare_palmitome_sets
  end

  def palmitome_stats
    
    params[:ref_organism_id]||=1
    @ref_organism = Organism.find(params[:ref_organism_id])
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})

    h_conditions = {
      :organism_id => @ref_organism.id
    }

    h_proteins = {}
    Protein.find_all_by_organism_id(@ref_organism.id).map{|p| h_proteins[p.id]=p}
   
    @all_studies = Study.find(:all, :conditions => {:large_scale => true}).select{|e| e.large_scale and e.cell_type and e.organism and e.hidden != true}
    palmitome_entries = PalmitomeEntry.find(:all, :conditions => h_conditions)
    
    @h_data = {
      :nber_prot_in_palmitome_study => {},
      :nber_prot_in_targeted_study => {},
      :nber_prot_in_palmitome_study_pred=> {},
      :nber_prot_in_targeted_study_pred => {}
    }
    
    (0 .. @all_studies.size).to_a.each do |nber_studies|
      @h_data[:nber_prot_in_palmitome_study][nber_studies]=0
      @h_data[:nber_prot_in_targeted_study][nber_studies]=0
      @h_data[:nber_prot_in_palmitome_study_pred][nber_studies]=0
      @h_data[:nber_prot_in_targeted_study_pred][nber_studies]=0
    end
    
    palmitome_entries.each do |pe|
      (0 .. pe.nber_palmitome_studies).to_a.each do |i|
        if @h_data[:nber_prot_in_palmitome_study][i]
          @h_data[:nber_prot_in_palmitome_study][i]+=1 
          @h_data[:nber_prot_in_targeted_study][i]+=1 if pe.targeted_study_ids != ''
          if h_proteins[pe.protein_id].has_hc_pred == true
            @h_data[:nber_prot_in_palmitome_study_pred][i]+=1 
            @h_data[:nber_prot_in_targeted_study_pred][i]+=1 if pe.targeted_study_ids != ''
          end
        end
      end
    end

     respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'palmitome_stats'}
      else
        format.html # show.html.erb                          
      end
    end
    
  end

  def palmitome_comparison

    helper = ApplicationController.helpers
    params[:ref_organism_id]||=1
    
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @ref_organism = Organism.find(params[:ref_organism_id])

#    palmitome_comparison_core(session[:studies])

    @h_studies = {}
    @h_cell_types = {}
    @h_organisms = {}
    @h_hits={} 
    @h_hit_lists = {}

    h_technique_categories = {}
    TechniqueCategory.all.each do |tc|
      h_technique_categories[tc.id]=tc.label
    end
    
    @h_technique_category_ids_by_technique_id = {}
    Technique.all.map{|t|
      @h_technique_category_ids_by_technique_id[t.id] = t.technique_category_id
    }
    
    @h_confidence_levels={}
    ConfidenceLevel.all.map{|cl| @h_confidence_levels[cl.id]=cl}

    h_cond ={:large_scale => true}
    h_cond[:hidden]=false if !lab_user? 

    @all_studies = Study.find(:all, :conditions => h_cond).select{|e| e.large_scale and e.cell_type and e.organism}

    @studies = []
    if session[:studies].size > 0
      h_tmp = h_cond
      h_tmp[:id]=session[:studies]
      @studies = Study.find(:all, :conditions => h_tmp)
    else
      @studies = Study.find(:all, :conditions => h_cond)
    end

    @studies= @studies.select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b|
      [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}    

    @h_sel_studies = {}
    @studies.map{|s| @h_sel_studies[s.id]=1}
    
    @h_techniques_by_study = {}
    Technique.find(:all, 
                   :select => "studies_techniques.study_id, techniques.id", 
                   :joins => 'join studies_techniques on (technique_id = techniques.id)', 
                   :conditions => ["studies_techniques.study_id in (?)", @h_sel_studies.keys]).each do |t|
      @h_techniques_by_study[t['study_id'].to_i] ||= []
      @h_techniques_by_study[t['study_id'].to_i].push(t['id'])
    end

    hit_lists = HitList.find(:all, :conditions => {:study_id => @studies.map{|s| s.id}})
    hit_lists.each do |hl|
      @h_hit_lists[hl.id]=hl
    end

    if !params[:nber_studies] or params[:nber_studies].to_i > @studies.size
      params[:nber_studies] = (@studies.size * 0.7).to_i
    end
    
    @all_studies.map{|s|
      @h_cell_types[s.cell_type_id] = s.cell_type;
      @h_organisms[s.organism_id] = s.organism;
      @h_studies[s.organism_id]||={}
      @h_studies[s.organism_id][s.cell_type_id]||=[]
      @h_studies[s.organism_id][s.cell_type_id].push(s)
    }
    
    h_conditions = {
      :organism_id => @ref_organism.id
    }
    
    @palmitome_entries = PalmitomeEntry.find(:all, :conditions => h_conditions).select{|e| 
      nber_palmitome_studies = e.palmitome_study_ids.split(',').select{|s| @h_sel_studies[s.to_i]}.size; 
      nber_targeted_studies = e.targeted_study_ids.split(",").size;
      nber_palmitome_studies >= params[:nber_studies].to_i and 
      (params[:nber_studies].to_i > 0 or (nber_palmitome_studies > 0 or nber_targeted_studies > 0))
    } 

    h_protein_ids = {}

#    @h_homologues_by_prot = {}
#    @h_hit_list_by_protein={}

#    @palmitome_entries.select!{|e| e.protein_id}

    @palmitome_entries.each do |e|
      #      @h_hit_list_by_protein[e.protein_id]||={}
      h_protein_ids[e.protein_id]=1
      #      @h_homologues_by_prot[e.protein_id]=[]
      e.orthologue_protein_ids.split(",").map{|pid| pid.to_i}.each do |pid|
        h_protein_ids[pid]=1
        #        @h_homologues_by_prot[e.protein_id].push(pid)
      end
      e.targeted_study_protein_ids.split(",").map{|pid| pid.to_i}.each do |pid|
        h_protein_ids[pid]=1
      end
      #      h_hit_lists = JSON.parse(e.hit_list_json)
      
      #      h_hit_lists.each_key do |study_id|
      #        @h_hit_list_by_protein[e.protein_id][study_id]=h_hit_lists[study_id]
      #      end      
    end
    
    @h_proteins = {}
    Protein.find(h_protein_ids.keys).map{|p| @h_proteins[p.id]=p}
    
    @h_main_isoforms ={}
    Isoform.find(:all, :conditions => {:protein_id => h_protein_ids.keys, :main => true}).map{|i| @h_main_isoforms[i.protein_id]=i}

    @h_gene_names = {}
    @h_targeted_studies = {}
    h_protein_ids.each_key do |pid|
      # @h_homologues_by_prot[pid]||=[]
      @h_gene_names[pid]=[]
      @h_targeted_studies[pid]=[]
    end

    RefProtein.find(:all, :conditions => {:source_type_id => 1, :protein_id => h_protein_ids.keys}).map{|rp| @h_gene_names[rp.protein_id].push(rp.value)}

    @protein_ids_by_interpro_id = {}
    @nber_palm_prot_by_interpro_id = {}
    @nber_prot_by_interpro_id = {}

    @h_interpro_desc = {}
    if params[:regroup_interpro] == '1'
      InterproMatch.find(:all, :conditions => {:protein_id => @palmitome_entries.map{|pe| pe.protein_id}}).map{|e|
        @protein_ids_by_interpro_id[e.interpro_id]||=[]
        @protein_ids_by_interpro_id[e.interpro_id].push(e.protein_id)
        @h_interpro_desc[e.interpro_id]=e.description
      }
      InterproMatch.find(:all, :conditions => {:interpro_id => @protein_ids_by_interpro_id.keys}).map{|e|
        @nber_palm_prot_by_interpro_id[e.interpro_id]||=0
        @nber_palm_prot_by_interpro_id[e.interpro_id]+=1
      }

      Interpro.find(:all, :conditions => {:id => @protein_ids_by_interpro_id.keys}).map{|e|
        tmp_h = JSON.parse(e.nber_proteins)
        @nber_prot_by_interpro_id[e.id]= (tmp_h[params[:ref_organism_id]]) ? tmp_h[params[:ref_organism_id]] : 0
      }
    end

    respond_to do |format|
      if params[:partial]
        if params[:regroup_interpro] == '1'
          format.html { render :partial => 'palmitome_comparison_interpro'}
        else
         format.html { render :partial => 'palmitome_comparison'}
        end
      else
        format.html # show.html.erb    
      end
      
      if params[:regroup_interpro] == '1'
      else
        format.text { 
          render text:
          ['UniProt AC', 'UniProt ID', 'Description', 'Gene names', @studies.map{|e| helper.format_study_name(e)}, "Homologues", "# of palmitome studies", "# of targeted studies", "Technique categories", "# of annotated sites", 'Potential false positive (main protein only)', '# of cysteines in the main isoform', '# of HC hits"'].flatten.join("\t") + "\n" +
          @palmitome_entries.map{|pe|
            hit_list=[]
            hit_list_ids_by_study = JSON.parse(pe.hit_list_json)
            h_techniques = {}
            nber_hc_hits = 0
            @studies.select{|s| @h_sel_studies[s.id]}.each do |study|
              if hit_list_ids_by_study and hit_list_ids = hit_list_ids_by_study[study.id.to_s] 
                #   hits = @h_hits[study.id][e.id]
                hit_list.push( hit_list_ids.map{ |hl_id|
                                 hl = @h_hit_lists[hl_id]
                                 to_display = (hl) ? (
                                         (hl.confidence_level_id) ? @h_confidence_levels[hl.confidence_level_id].tag : ((hl.label!= '') ? hl.label : 'Yes')
                                         ) : 'Paper'
                                 nber_hc_hits += 1 if to_display == 'HC'
                                 to_display
                               }.uniq.join(", "))
                @h_techniques_by_study[study.id].map{|tid| h_techniques[tid]=1} if  @h_techniques_by_study[study.id]
              else
                hit_list.push('-')
              end
            end
            e = @h_proteins[pe.protein_id];
            [e.up_ac, e.up_id, e.description, @h_gene_names[e.id].join(', '),
             hit_list,
             pe[:orthologue_protein_ids].split(',').map{|pid| p=@h_proteins[pid.to_i]; ((p) ? p.up_id : 'NA')}.join(", "),
             pe.palmitome_study_ids.split(',').select{|s| @h_sel_studies[s.to_i]}.size,
             pe.targeted_study_ids.split(',').size,
             #             <td><%= pe.technique_ids.split(',').map{|tid| @h_technique_category_ids_by_technique_id[tid.to_i]}.compact.size %></td>
             #pe.technique_ids.split(',').map{|tid| @h_technique_category_ids_by_technique_id[tid.to_i]}.compact.size,             
#             h_techniques.keys.map{|tid| @h_technique_category_ids_by_technique_id[tid]}.uniq.size,
#             e.nber_technique_categories_public,
             h_techniques.keys.map{|tid| @h_technique_category_ids_by_technique_id[tid]}.uniq.map{|e| h_technique_categories[e]}.join(", "),
             pe.annotated_site_ids.split(',').size,
             (e.fp_chem == true or e.fp_label or e.fp_go) ? 'FP' : '-',
              @h_main_isoforms[pe.protein_id].seq.scan("C").size,
             nber_hc_hits
            ].flatten.join("\t")
          }.join("\n")}
        #      format.json {}            
      end
    end
  end
  
  def palmitome_comparison_old

   helper = ApplicationController.helpers

#    session[:studies]||= []
    params[:ref_organism_id]||=1

    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})

    @ref_organism = Organism.find(params[:ref_organism_id])

    #### retrieve the orthologies in 1 direction protein lambda (having hits) -> Orthologue in the reference organism
    @h_orthologues={}
    Orthologue.find(:all, 
                    :joins => 'join proteins on (proteins.id = orthologues.protein_id1)', 
                    :conditions => {:proteins => {:organism_id => @ref_organism.id}}).map{|e| 
      @h_orthologues[e.protein_id2]||=[];
      @h_orthologues[e.protein_id2].push(e.protein_id1)
    }
    
    Orthologue.find(:all,
                    :joins => 'join proteins on (proteins.id = orthologues.protein_id2)',
                    :conditions => {:proteins => {:organism_id => @ref_organism.id}}).map{|e| 
      @h_orthologues[e.protein_id1]||=[];
      @h_orthologues[e.protein_id1].push(e.protein_id2)
    }
    
    @h_hits={}
    @h_studies = {}
    @h_cell_types = {}
    @h_organisms = {}

    @all_studies = Study.find(:all, :conditions => {:large_scale => true}).select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b| [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}
    session[:studies].delete_if{|e| !@all_studies.map{|e2| e2.id}.include?(e)}

    ### reject studies that are hidden                                                                                                                                                           
    @all_studies.reject!{|e| e.hidden == true} if !lab_user? and !admin?

    @studies = []
    if session[:studies].size > 0
      @studies = Study.find(:all, :conditions => {:large_scale => true, :id => session[:studies]})
    else
      @studies = Study.find(:all, :conditions => {:large_scale => true})
    end

    @studies= @studies.select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b| 
      [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}

    if !params[:nber_studies] or params[:nber_studies].to_i > @studies.size
      params[:nber_studies] = (@studies.size * 0.7).to_i
    end

    @all_studies.map{|s|
      @h_cell_types[s.cell_type_id] = s.cell_type;
      @h_organisms[s.organism_id] = s.organism;
      @h_studies[s.organism_id]||={}
      @h_studies[s.organism_id][s.cell_type_id]||=[]
      @h_studies[s.organism_id][s.cell_type_id].push(s)
    }
    @studies.map{|s|
      @h_hits[s.id]={};
    }

    @h_confidence_levels={}
    ConfidenceLevel.all.map{|cl| @h_confidence_levels[cl.id]=cl}

    @h_hit_lists = {}
    HitList.find(:all, :conditions => {:study_id => @h_hits.keys}).map{|hl| @h_hit_lists[hl.id]=hl}

    @hits=Hit.find(:all, :joins => 'join proteins on (proteins.id = hits.protein_id)', :conditions => #[" nber_studies >= ? and 
                  ["hits.study_id in (?)", @studies.map{|s| s.id}]) # {:proteins => {:organism_id =>  @organism.id}}) 

    ### select only hits present in the selected studies
    @selected_hits = @hits.select{|h| @h_hits[h.study_id]}

    ## get proteins first pass + complement pass for orthologues and closest sp proteins
    @h_proteins={}
    list_complement_proteins = []

    Protein.find(@selected_hits.map{|h| h.protein_id}.uniq).each do |p|
      @h_proteins[p.id]=p
      if p.closest_sp_protein_id
        list_complement_proteins.push(p.closest_sp_protein_id)
      end
      if p.organism_id != params[:ref_organism_id].to_i and @h_orthologues[p.id]
        list_complement_proteins+=@h_orthologues[p.id]
      end
    end
    proteins2 = Protein.find(list_complement_proteins)
    proteins2.each do |p|
      @h_proteins[p.id]=p
    end
    

    ### compute studies by protein and hits by studies and protein taking into account orthology + record of complementary orthologues using closest SP protein
    @h_study_by_prot={}
    h_compl_orthologues = {}
    @selected_hits.map{|h|
      
      ### change protein to the right organism
      protein_ids = (@h_proteins[h.protein_id].organism_id == params[:ref_organism_id].to_i) ?  [h.protein_id] : ((@h_orthologues[h.protein_id]) ? @h_orthologues[h.protein_id] : [])
      
      protein_ids.map{|pid| 
        new_pid = pid
        if (@h_proteins[pid].closest_sp_protein_id) 
          new_pid = @h_proteins[pid].closest_sp_protein_id
          h_compl_orthologues[new_pid]||=[]
          h_compl_orthologues[new_pid].push(h.protein_id)
        end
        new_pid
      }.each do |protein_id|
        
        if protein_id
          @h_study_by_prot[protein_id]||={}
          @h_study_by_prot[protein_id][h.study_id]=1;
          @h_hits[h.study_id][protein_id]||=[];
          @h_hits[h.study_id][protein_id].push(h)
        end
      end
    }

    ### apply the complement of orthology (closest SP protein)
    tmp_list_proteins = @h_study_by_prot.each_key.map{|pid|
      if h_compl_orthologues[pid]
        h_compl_orthologues[pid].each do |hit_pid|
          @h_orthologues[hit_pid]||=[]
          @h_orthologues[hit_pid].push(pid)
        end
      end
      pid
    }.select{|pid|
      @h_study_by_prot[pid].keys.size >params[:nber_studies].to_i-1
    }

    ### compute homologues
    @h_homologues_by_prot = {}
    tmp_list_proteins.each do |pid|      
      @h_homologues_by_prot[pid]={}
      @selected_hits.each do |h|
        if @h_orthologues[h.protein_id] 
          if @h_orthologues[h.protein_id].include?(pid) 
            @h_homologues_by_prot[pid][h.protein_id]=1 if h.protein_id != pid
            @h_orthologues[h.protein_id].map{|o| @h_homologues_by_prot[pid][o]=1  if o != pid}
          end
        end
      end      
    end
   
    ### discard the proteins that are already taken into account in the orthologues
    h_represented_protein = {}
    @proteins = []

    tmp_list_proteins.sort{|a, b| @h_study_by_prot[b].keys.size <=> @h_study_by_prot[a].keys.size}.each do |p1_id|
      flag_homologue_represented = 0
      @h_homologues_by_prot[p1_id].each_key do |p2_id|
        flag_homologue_represented = 1 if h_represented_protein[p2_id]
      end
      if !h_represented_protein[p1_id] or flag_homologue_represented==0
        @proteins.push(@h_proteins[p1_id]) if @h_proteins[p1_id]
      end 
      h_represented_protein[p1_id]=1
      if @h_homologues_by_prot[@h_proteins[p1_id]]
        @h_homologues_by_prot[@h_proteins[p1_id]].each_key do |p2_id|
          h_represented_protein[p2_id]=1
        end       
      end
    end

    @h_gene_names = {}
    @h_targeted_studies = {}
    @h_proteins.each_key do |pid| 
      @h_gene_names[pid]=[]
      @h_targeted_studies[pid]=[]      
    end
   
    RefProtein.find(:all, :conditions => {:source_type_id => 1, :protein_id => @h_proteins.keys}).map{|rp| @h_gene_names[rp.protein_id].push(rp.value)}

    @h_annotated_hits={}
    @annotated_hits = Hit.find(:all, :conditions => {#:protein_id => @h_proteins.keys, 
                                 :hit_list_id => nil})
    @annotated_hits.map{|h| @h_annotated_hits[h.id]=h}
    @annotated_sites = Site.find(:all, :conditions => {:hit_id => @annotated_hits.map{|e| e.id}})


    #  @h_targeted_studies = {}
    #  @proteins.map{|p| @h_targeted_studies[p.id]=[]}
    @targeted_studies = Study.find(:all, :conditions => {:id => @annotated_hits.map{|e| 
                                       list_ids = (@h_orthologues[e.protein_id]) ? @h_orthologues[e.protein_id] : [e.protein_id]
                                       list_ids.map{|e2| 
                                         @h_targeted_studies[e2]||=[]; 
                                         @h_targeted_studies[e2].push(e.study_id) if !@h_targeted_studies[e2].include?(e.study_id) 
                                       }
                                       e.study_id
                                     }.uniq})
    #    @targeted_studies = @annotated_hits.select{|e| (@h_orthologues[e.protein.id] and @h_orthologues[e.protein.id].include?(protein.id)) or e.protein.id == protein.id }.map{|e| e.study_id}.uniq
    all_targeted_and_palmitome_study_ids = (@annotated_hits.map{|e| e.study_id} + @all_studies.map{|e| e.id}).uniq
    
    techniques = Technique.find(:all, :select => 'study_id, technique_id', :joins => 'join studies_techniques on (technique_id = techniques.id)', :conditions => {:studies_techniques => {:study_id => @h_hits.keys}})# @annotated_hits.map{|e| e.study_id}}})
    @h_techniques_by_study = {}
    techniques.select{|e| e.technique_id}.map{|e|
      technique_id = (e.technique_id.to_i == 2) ? 1 : e.technique_id.to_i;
      @h_techniques_by_study[e.study_id.to_i]||=[];
      @h_techniques_by_study[e.study_id.to_i].push(technique_id) if !@h_techniques_by_study[e.study_id.to_i].include?(technique_id) #and technique_id != nil
    }
    #
    #    techniques.compact.map{|e|       
    #      technique_id = (e.technique_id.to_i == 2) ? 1 : e.technique_id.to_i;
    #      @h_techniques_by_study[e.study_id.to_i]||=[];
    #      @h_techniques_by_study[e.study_id.to_i].push(technique_id) if !@h_techniques_by_study[e.study_id.to_i].include?(technique_id) and technique_id
    #   }
    
    respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'palmitome_comparison'}
      else
        format.html # show.html.erb                                                                                             
      end

      format.text { render text:
        ['UniProt AC', 'UniProt ID', 'Description', 'Gene names', @studies.map{|e| helper.format_study_name(e)}, "# of palmitome studies", "# of targeted studies", "# of technique categories", "# of annotated sites"].flatten.join("\t") + "\n" +
        @proteins.map{|e|
          hit_list=[]
          @studies.each do |study|
            if (@h_hits[study.id][e.id])
              hits = @h_hits[study.id][e.id]
              hit_list.push( hits.map{ |h|
                               hl = @h_hit_lists[h.hit_list_id]
                               (hl) ? (
                                       (hl.confidence_level_id) ? @h_confidence_levels[hl.confidence_level_id].tag : ((hl.label!= '') ? hl.label : 'Yes')
                                       ) : 'Paper'
                             }.uniq.join(", "))
            else
              hit_list.push('-')
            end
          end

          [e.up_ac, e.up_id, e.description, @h_gene_names[e.id].join(', '),
           hit_list, 
           @h_study_by_prot[e.id].keys.size,
           @h_targeted_studies[e.id].size,
           (@h_targeted_studies[e.id] + @h_study_by_prot[e.id].keys).uniq.map{|study_id| @h_techniques_by_study[study_id]}.flatten.uniq.size,
           @annotated_sites.select{|as| hit = @h_annotated_hits[as.hit_id]; (@h_orthologues[hit.protein_id] and @h_orthologues[hit.protein_id].include?(e.id)) or hit.protein_id == e.id}.size
          ].flatten.join("\t")
        }.join("\n")}
      #      format.json {}
    end
    
  end
  
  def get_pat_apt
    
    res = [{},{}]
    
    data = [
            Reaction.all.select{|e| e.is_a_pat == true},
            Reaction.all.select{|e| e.is_a_pat == false}
           ]
    
    data_prot = [
                 Protein.find(:all, :conditions => {:is_a_pat => true}),
                 Protein.find(:all, :conditions => {:is_a_pat => false})
                ]
    
    data_prot.each_index do |i|
      data_prot[i].each do |protein|
        res[i][protein.organism_id]||={}
        res[i][protein.organism_id][protein]||={}
      end
    end
    data.each_index do |i|
      data[i].each do |pat|
        protein = pat.protein
        res[i][protein.organism_id]||={}
        res[i][protein.organism_id][protein]||={}
        site = pat.site
        if pat.site
          subst_protein = site.hit.protein
          res[i][protein.organism_id][protein][subst_protein]||={}
          res[i][protein.organism_id][protein][subst_protein][site.pos]||=0
          res[i][protein.organism_id][protein][subst_protein][site.pos]+=1
        elsif pat.hit
          subst_protein = pat.hit.protein
          res[i][protein.organism_id][protein][subst_protein]||={}
          res[i][protein.organism_id][protein][subst_protein][nil]||=0
          res[i][protein.organism_id][protein][subst_protein][nil]+=1
        end
      end
    end
    
    return res
  end
  
  def pat_apt_summary
    helper = ApplicationController.helpers

    res = get_pat_apt()

    headers = ['Enzyme UniProt AC', 'Enzyme UniProt ID', '#', 'Isoforms', 'Homology group', 'Substrate UniProt AC', 'Substrate UniProt ID', '# position-unspecific evidences', 'Sites']

    @final_res  =[{},{}]
    res.each_index do |i|

      #      #add header
      #      @final_res[i].push(headers)
      
      #add data
      res[i].each_key do |o|
        #add header                                                                                                                                                             
        @final_res[i][o]||=[]
        @final_res[i][o].push(headers)

        res[i][o].each_key do |p|
          selected_isoforms=p.isoforms.select{|i| i.latest_version == true}
          isoforms_txt = selected_isoforms.map{|i| i.isoform}.sort.join(", ")
          homology_groups_txt = selected_isoforms.map{|i| (i.pat_isoform) ? i.pat_isoform.homology_group : nil}.compact.uniq.sort.join(', ')
          first_part_up_id = p.up_id.split("_")[0]
          if res[i][o][p].keys.size > 0
            res[i][o][p].each_key do |sp|
              tmp = [
                     ("<span style='white-space:nowrap'>" + helper.uniprot_link(p) + " " +  helper.link_to(p.up_ac, protein_path(p)) + "</span>"), 
                     p.up_id, 
                     ((m = first_part_up_id.match(/^ZDH.*?(\d+)$/)) ? m[1] : ((m = p.description.match(/Palmitoyltransferase Z.*?(\d+)/)) ? m[1] : '')),
                     isoforms_txt,
                     homology_groups_txt,
                     ("<span style='white-space:nowrap'>" + helper.uniprot_link(sp) + " " +  helper.link_to(sp.up_ac, protein_path(sp)) + "</span>"), 
                     sp.up_id
                    ]
              tmp.push((res[i][o][p][sp][nil]) ? res[i][o][p][sp][nil] : '0')
              tmp.push(res[i][o][p][sp].keys.select{|e| e}.map{|pos| "Cys<sup>#{pos}</sup>(#{res[i][o][p][sp][pos]} evidence#{(res[i][o][p][sp][pos] == 1) ? '' : 's'})"}.join(', '))
              @final_res[i][o].push(tmp)
            end
          else
            tmp = [
                   ("<span style='white-space:nowrap'>" + helper.uniprot_link(p) + " " +  helper.link_to(p.up_ac, protein_path(p)) + "</span>"),
                   p.up_id,
                   ((m = first_part_up_id.match(/^ZDH.*?(\d+)$/)) ? m[1] : ''),
                   isoforms_txt,
                   homology_groups_txt,
                   ("<span style='white-space:nowrap'></span>"),
                   '',
                   '',
                   ''
                  ]
            @final_res[i][o].push(tmp)
          end
        end
      end
    end

  end

  def pat_by_homology_group

     helper = ApplicationController.helpers

    annotated_pat = Protein.find(:all, :conditions => {:is_a_pat => true})
    h_annotated_pat = {}
    annotated_pat.map{|e| h_annotated_pat[e.id]=1}
    
    pat_isoforms = PatIsoform.all
    isoforms = Isoform.find(:all, :conditions => {:id => pat_isoforms.map{|i| i.isoform_id}})
    pats = Protein.find(:all, :conditions => {:id => isoforms.map{|e| e.protein_id}.uniq})
    #    homologues = Homologue.find(:all, :conditions => {:isoform_id1 => pat_isoforms.})
    
    headers = ['Enzyme UniProt AC', 'Enzyme UniProt ID', 'Organism', 'Description', '#', 'Isoforms', '# of Hits', 'Annotated PAT?']
    
    @final_res  = {}
    pats.each_index do |i|
      
      p = pats[i]
      selected_isoforms = p.isoforms.select{|i| i.latest_version == true}
      isoforms_txt = selected_isoforms.map{|i| i.isoform}.sort.join(", ")
      first_part_up_id = p.up_id.split("_")[0]
      
      homology_groups = selected_isoforms.map{|i| (i.pat_isoform) ? i.pat_isoform.homology_group : nil}.compact.uniq.sort
      
      homology_groups.each do |homology_group|
        if !@final_res[homology_group]
          @final_res[homology_group]=[headers]
        end
        v = [
             p.up_ac,
             p.up_id,
             (p.organism) ? p.organism.name : 'NA',
             p.description,
             ((m = first_part_up_id.match(/^ZDH.*?(\d+)$/)) ? m[1] : ((m = p.description.match(/Palmitoyltransferase Z.*?(\d+)/)) ? m[1] : '')),
             isoforms_txt,             
             p.hits.size,
             (h_annotated_pat[p.id]) ? 'Yes' :'No'
            ]
        @final_res[homology_group].push(v)
      end
    end
    
  end

  def pat_phylip_nj_tree
    if params[:group]
      #   filepath=Pathname.new(APP_CONFIG[:data_dir]) + "orthologues" + "alignments" + '12.neigh.constree.js'
      filepath=Pathname.new(APP_CONFIG[:data_dir]) + "orthologues" + "alignments" + "#{params[:group]}.neigh.constree"
      
      f = File.open(filepath, 'r')
      
      #    @json = f.readlines.join('') 
      tmp = f.readlines.map{|l| 
        l.chomp;
      }.join("");
      @data_newick = tmp.dup
      tmp.scan(/[0-9]+\|[0-9A-Z]+/).each do |e|
        tab = e.split("|")
        if tab.size > 0
          isoform = Isoform.find(tab[0])
          protein = isoform.protein
          gene_names = protein.ref_proteins.select{|rp| rp.source_type and  rp.source_type.name == 'gene_name'}.map{|e| e.value}.join("/").gsub(":", "_");
          new_text = protein.up_id + " [" + protein.up_ac + ((isoform.main == true) ? '' : "-#{isoform.isoform}") + "]" 
          new_text += "[" + gene_names + "]" if gene_names.size > 0
          @data_newick.gsub!(e, new_text)
        end
      end
    end
  end

  def pat_graph
    
    organisms = Organism.all
    h_organisms={}
    organisms.map{|o| h_organisms[o.id] = o}
    @h_organisms = {}

#    @nber_organisms=organisms.size

    res = get_pat_apt()

    nodes = []
    links = []
    h_nodes ={}
    h_links={}
    res.each_index do |i|
      res[i].each_key do |o|
        res[i][o].each_key do |p|
          p.isoforms.select{|i| i.latest_version}.each do |isoform|
            if !h_nodes[isoform.id] and pat_isoform = isoform.pat_isoform
              nodes.push({
                           :name => p.up_id + " " + p.up_ac + "-" + isoform.isoform.to_s, #+ " " + isoform.id.to_s + " " + isoform.homology_group.to_s, 
                           :group => (params[:color_scheme] == 'group') ? pat_isoform.homology_group : p.organism_id
                       })
              @h_organisms[p.organism_id]=h_organisms[p.organism_id]
              h_nodes[isoform.id]= nodes.size-1
            end
            homologues=Homologue.find(:all, :conditions =>{:isoform_id1 => isoform.id} )
            pat_isoforms = PatIsoform.find(:all, :conditions => {:isoform_id => homologues.map{|e| e.isoform_id2}})
            pat_isoforms.each do |pat_isoform2|
              isoform2 = pat_isoform2.isoform
              hp = isoform2.protein              
              if !h_nodes[isoform2.id]
                @h_organisms[hp.organism_id]=h_organisms[hp.organism_id]
                nodes.push({
                             :name => hp.up_id + " " + hp.up_ac + "-" + isoform2.isoform.to_s, 
                             :group =>  (params[:color_scheme] == 'group') ? pat_isoform2.homology_group : hp.organism_id
                           })
                h_nodes[isoform2.id]= nodes.size-1
              end
            end
            homologues.each do |h|
              l = [h.isoform_id1, h.isoform_id2].sort
              if h_nodes[h.isoform_id1] and h_nodes[h.isoform_id2] and !h_links[l.join(":")] and (!params[:evalue_threshold] or (!h.evalue_power or h.evalue_power < params[:evalue_threshold].to_i)) 
                links.push({:source => h_nodes[h.isoform_id1], :target => h_nodes[h.isoform_id2], :value => (params[:evalue_threshold]) ? 1 : (h.id_percent/10).to_i})
                h_links[l.join(":")]=1
              end
            end
          end
        end
      end
    end

    @graph_data= {:nodes => nodes, :links => links}


  end


  def browse
  end

  def contact
  end

  def about
  end

  def pubmed
  end
  def prediction
  end
  def what
  end
  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end
end
