class OrganismsController < ApplicationController

before_filter :authorize


  def common_prot_in_palmitomes

    @h_common = {}
    @h_organisms = {}
    Organism.all.map{|o| @h_organisms[o.id]=o}
    @headers = @h_organisms.keys.sort{|a, b| @h_organisms[a].name <=> @h_organisms[b].name}
    @dataset = params[:dataset]
    
    h_validated = {}
    if @dataset == 'validated'
      Protein.find(:all, :conditions => {:validated_dataset => true}).map{|p| h_validated[p.id]=1}
    end
    
    @h_organisms.each_key do |oid|
      o = @h_organisms[oid]
      #      h_tmp = JSON.parse(o.prot_common_in_palmitomes_json)
      h_tmp = (@dataset == 'validated') ? JSON.parse(o.prot_common_in_palmitomes_json_val) : JSON.parse(o.prot_common_in_palmitomes_json)
      @h_common[o.id]={} if h_tmp and h_tmp.keys.size > 0
      h_tmp.each_key do |k|
        @h_common[o.id][k.to_i]=h_tmp[k]
      end
    end
    
    @h_common.each_key do |k|
      @h_common[k][k] = @h_organisms[k].palmitome_entries.select{|e| @dataset != 'validated' or h_validated[e.protein_id]}
    end
    @headers = @h_common.keys.select{|oid| @h_common[oid].keys.size > 0}.sort{|a, b| @h_organisms[a].name <=> @h_organisms[b].name}
    
  end


  def diff_prot_in_palmitomes

    @h_diff = {}
    @h_organisms = {}
    Organism.all.map{|o| @h_organisms[o.id]=o}
    @headers = @h_organisms.keys.sort{|a, b| @h_organisms[a].name <=> @h_organisms[b].name}
    @dataset = params[:dataset]

    h_validated = {}
    if @dataset == 'validated'
      Protein.find(:all, :conditions => {:validated_dataset => true}).map{|p| h_validated[p.id]=1}
    end

    @h_organisms.each_key do |oid|
      o = @h_organisms[oid]
      h_tmp = (@dataset == 'validated') ? JSON.parse(o.prot_diff_in_palmitomes_json_val) : JSON.parse(o.prot_diff_in_palmitomes_json)
      @h_diff[o.id]={} if h_tmp and h_tmp.keys.size > 0
      h_tmp.each_key do |k|
        @h_diff[o.id][k.to_i]=h_tmp[k]
      end
    end

    @h_diff.each_key do |k|
      @h_diff[k][k] = @h_organisms[k].palmitome_entries.select{|e| @dataset != 'validated' or h_validated[e.protein_id]}

    end

    @headers = @h_diff.keys.select{|oid| @h_diff[oid].keys.size > 0}.sort{|a, b| @h_organisms[a].name <=> @h_organisms[b].name}

  end

  def phosphosite_stats

    params[:status]||=0
    params[:ref_organism_id]||=1
    threshold = params[:status].to_i
    @organism = Organism.find(params[:ref_organism_id].to_i)
    @dataset = params[:dataset]

    h_cond = {:organism_id => @organism.id}
    h_cond[:validated_dataset] = true if @dataset == 'validated'

    h_proteins = {}
    h_isoforms= {}
    h_predictions = {}

    h_phosphosite_types = {}
    PhosphositeType.all.map{|e| h_phosphosite_types[e.id]=e}
    
    Protein.find(:all, :conditions => {:organism_id => @organism.id}).each do |p|
      h_proteins[p.id]=p
      h_predictions[p.id]=0
    end

    Isoform.find(:all, :conditions => {:protein_id => h_proteins.keys#.select{|k| @dataset != 'validated' or h_proteins[k].validated_dataset == true}
                 }).each do |i|
      h_isoforms[i.id]=i
    end

    palm_prots = h_proteins.keys.select{|p| h_proteins[p].has_hits_public == true}
    tm_prots = Feature.find(:all, :conditions => {:feature_type_id => 1}).map{|f| f.protein_id}.uniq
    h_tm_prots = {}
    tm_prots.each do |pid|
      h_tm_prots[pid]=1
    end

    
    @h_sl={}
    
    @h_res = {}
    @h_res2 = {
      :nber_palm_prot => h_proteins.keys.select{|p| h_proteins[p].has_hits_public == true}.size,
      :nber_palm_tm_prot => (palm_prots & tm_prots).size,
      :nber_palm_prot_ortho => h_proteins.keys.select{|p| h_proteins[p].has_hits_ortho_public == true}.size,
      :nber_palm_prot_pred =>  h_proteins.keys.select{|p| h_proteins[p].has_hc_pred == true}.size
    }

    @ptms = PhosphositeFeature.find(:all, :select => 'isoform_id, phosphosite_features.*', :conditions => {:isoform_id => h_isoforms.keys}) # {:proteins => {:organism_id => @organism.id}}).uniq

    h_by_prot = {}

    @ptms.each do |ptm|      
      h_by_prot[h_isoforms[ptm.isoform_id.to_i].protein_id]||=[]
      h_by_prot[h_isoforms[ptm.isoform_id.to_i].protein_id].push(ptm)
    end

    h_by_prot.each_key do |pid|
      list_ptm_ids = h_by_prot[pid].map{|ptm| h_phosphosite_types[ptm.phosphosite_type_id].name}.uniq.sort
      list_of_items = [list_ptm_ids]
      if params[:uniq]=='1'
        list_of_items = list_ptm_ids.map{|e| [e]}
      end
      list_of_items.each do |item|
        @h_res[item]||={:nber_all_prot => 0,  :nber_tm_prot => 0, :nber_palm_prot => 0, :nber_palm_tm_prot => 0, :nber_palm_prot_ortho => 0, :nber_palm_predicted_prot => 0}
        @h_res[item][:nber_all_prot]+=1
        @h_res[item][:nber_tm_prot]+=1 if h_tm_prots[pid]

        if h_proteins[pid]
          @h_res[item][:nber_palm_prot]+=1 if h_proteins[pid].has_hits_public == true
          @h_res[item][:nber_palm_tm_prot]+=1 if h_proteins[pid].has_hits_public == true and h_tm_prots[pid]
          @h_res[item][:nber_palm_prot_ortho]+=1 if h_proteins[pid].has_hits_ortho_public == true
          @h_res[item][:nber_palm_predicted_prot]+=1 if h_proteins[pid].has_hc_pred == true
        end
      end
    end

      respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'ptm_stats'}
      else
        format.html # index.html.erb                                                                                                                                                                                                                                           
        format.text { render text: ["PTM", "Total number of proteins", "Number of palmitoylated proteins", "% of palmitoylated proteins", "Number of proteins predicted to be palmitoylated", "% of proteins predicted to be palmitoylated"].join("\t") + "\n" +
          @h_res.keys.map{|item|
            [item,
             @h_res[item][:nber_all_prot],
            @h_res[item][:nber_palm_prot],
            (@h_res[item][:nber_palm_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_prot_ortho],
             (@h_res[item][:nber_palm_prot_ortho].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_predicted_prot],
             (@h_res[item][:nber_palm_predicted_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i
            ].join("\t")
          }.join("\n")
        }
        format.json { render json: @organism }
      end
    end
  end

  def protein_complex_stats
    
    params[:status]||=0
    params[:ref_organism_id]||=1
    threshold = params[:status].to_i
    @organism = Organism.find(params[:ref_organism_id].to_i)
    @dataset = params[:dataset]
    
    @protein_complexes = ProteinComplex.find(:all, :conditions => {:organism_id => @organism.id})
    
       respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'protein_complex_stats'}
      else
        format.html # index.html.erb          
        format.text { render text: ["Complex", "Total number of proteins", "Number of palmitoylated proteins", "% of palmitoylated proteins", "Number of proteins predicted to be palmitoylated", "% of proteins predicted to be palmitoylated"].join("\t") + "\n" +
          @protein_complexes.map{|pc|
            nber_palm = (params[:dataset] == 'validated') ? pc.nber_prot_validated_dataset : pc.nber_prot_palm;
            [pc.name,
             pc.nber_prot,
             nber_palm,
             nber_palm.to_f * 100 / pc.nber_prot,
             pc.nber_prot_predicted,
             pc.nber_prot_predicted.to_f * 100 / pc.nber_prot
            ].join("\t")
          }.join("\n")
        }
        format.json { render json: @organism }
      end
    end


  end


  def uniprot_domain_stats
    
    params[:status]||=0
    params[:ref_organism_id]||=1
    threshold = params[:status].to_i
    @organism = Organism.find(params[:ref_organism_id].to_i)
    @dataset = params[:dataset]

    h_cond = {:organism_id => @organism.id}
    h_cond[:validated_dataset] = true if @dataset == 'validated'

    h_proteins = {}
    h_isoforms= {}
    h_predictions = {}

    Protein.find(:all, :conditions => h_cond).each do |p|
      h_proteins[p.id]=p
      h_predictions[p.id]=0
    end

    palm_prots = h_proteins.keys.select{|p| h_proteins[p].has_hits_public == true}
    tm_prots = Feature.find(:all, :conditions => {:feature_type_id => 1}).map{|f| f.protein_id}.uniq
    h_tm_prots = {}
    tm_prots.each do |pid|
      h_tm_prots[pid]=1
    end

    sites = Site.all
    

    @h_res = {}
    @h_res2 = {
      :nber_palm_prot => palm_prots.size,
      :nber_palm_tm_prot => (palm_prots & tm_prots).size,
      :nber_tm_prot => tm_prots.size ,
      :nber_palm_prot_ortho => h_proteins.keys.select{|p| h_proteins[p].has_hits_ortho_public == true}.size,
      :nber_palm_prot_pred =>  h_proteins.keys.select{|p| h_proteins[p].has_hc_pred == true}.size
    }
    @uniprot_domains = Feature.find(
                         :all,
                         :select => 'protein_id, features.*',
                         :joins => 'join proteins on (proteins.id = protein_id)',
                         :conditions => {:feature_type_id => 10, :proteins =>{:organism_id => @organism.id}}
                         )

    h_by_prot = {}

    @uniprot_domains.each do |dom|
      h_by_prot[dom.protein_id.to_i]||=[]
      h_by_prot[dom.protein_id.to_i].push(dom)
    end
    
    @h_nber_sites = {}

    sites.each do |site|
      hit = site.hit
      if h_by_prot[hit.protein_id] and (!hit.isoform or hit.isoform.main == true)
        h_by_prot[hit.protein_id].each do |dom|
          if site.pos >= dom.start and site.pos <= dom.stop
            @h_nber_sites[dom.description.split('; ').first]||=0
            @h_nber_sites[dom.description.split('; ').first]+=1
          end
        end
      end
    end
    
    h_by_prot.each_key do |pid|
      
      list_dom_ids = h_by_prot[pid].select{|dom| dom.status <= threshold}.map{|dom| dom.description.split('; ').first}.uniq.sort
      
      list_of_items = [list_dom_ids]
      if params[:uniq]=='1'
        list_of_items = list_dom_ids.map{|e| [e]}
      end
      list_of_items.each do |item|
        @h_res[item]||={
          :nber_all_prot => 0,
          :nber_tm_prot => 0,
          :nber_palm_tm_prot => 0,
          :nber_palm_prot => 0,
          :nber_palm_prot_ortho => 0,
          :nber_palm_predicted_prot => 0
        }
        @h_res[item][:nber_all_prot]+=1
        
        @h_res[item][:nber_tm_prot]+=1 if h_tm_prots[pid]
        if h_proteins[pid]
          @h_res[item][:nber_palm_prot]+=1 if h_proteins[pid].has_hits_public == true
          @h_res[item][:nber_palm_tm_prot]+=1 if h_proteins[pid].has_hits_public == true and  h_tm_prots[pid]
          @h_res[item][:nber_palm_prot_ortho]+=1 if h_proteins[pid].has_hits_ortho_public == true
          @h_res[item][:nber_palm_predicted_prot]+=1 if h_proteins[pid].has_hc_pred == true
        end
      end
    end
    
    respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'uniprot_domain_stats'}
      else
        format.html # index.html.erb                                                                                                                                                                                        \
        
        format.text { render text: ["Domain", "Total number of proteins", "Number of palmitoylated proteins", "% of palmitoylated proteins", "Number of proteins predicted to be palmitoylated", "% of proteins predicted to be palmitoylated"].join("\t") + "\n" +
          @h_res.keys.map{|item|
            [item,
             @h_res[item][:nber_all_prot],
             @h_res[item][:nber_palm_prot],
             (@h_res[item][:nber_palm_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_prot_ortho],
             (@h_res[item][:nber_palm_prot_ortho].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_predicted_prot],
             (@h_res[item][:nber_palm_predicted_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_tm_prot],
             @h_res[item][:nber_palm_tm_prot],
             (@h_res[item][:nber_palm_tm_prot].to_f * 100 /  @h_res[item][:nber_tm_prot]).to_i
            ].join("\t")
          }.join("\n")
        }
        format.json { render json: @organism }
      end
    end
  end

  
  def ptm_stats

    params[:status]||=0
    params[:ref_organism_id]||=1
    threshold = params[:status].to_i
    @organism = Organism.find(params[:ref_organism_id].to_i)
    @dataset = params[:dataset]
    
    h_cond = {:organism_id => @organism.id}
    h_cond[:validated_dataset] = true if @dataset == 'validated'
    
    h_proteins = {}
    h_isoforms= {}
    h_predictions = {}
    
    Protein.find(:all, :conditions => h_cond).each do |p|
      h_proteins[p.id]=p
      h_predictions[p.id]=0
    end

    @h_sl={}
   # .all.each do |sl|
   #   @h_sl[sl.id]=sl
   # end

    palm_prots = h_proteins.keys.select{|p| h_proteins[p].has_hits_public == true}
    tm_prots = Feature.find(:all, :conditions => {:feature_type_id => 1}).map{|f| f.protein_id}.uniq
    h_tm_prots = {}
    tm_prots.each do |pid|
      h_tm_prots[pid]=1
    end
    
    @h_res = {}
    @h_res2 = {
      :nber_palm_prot => palm_prots.size,
      :nber_palm_tm_prot => (palm_prots & tm_prots).size,
      :nber_tm_prot => tm_prots.size ,
      :nber_palm_prot_ortho => h_proteins.keys.select{|p| h_proteins[p].has_hits_ortho_public == true}.size,
      :nber_palm_prot_pred =>  h_proteins.keys.select{|p| h_proteins[p].has_hc_pred == true}.size
    }
    @ptms = Feature.find(
                         :all, 
                         :select => 'protein_id, features.*',
                         :joins => 'join proteins on (proteins.id = protein_id)', 
                         :conditions => {:feature_type_id => 4, :proteins =>{:organism_id => @organism.id}}
                         )

    h_by_prot = {}

    @ptms.each do |ptm|
      h_by_prot[ptm.protein_id.to_i]||=[]
      h_by_prot[ptm.protein_id.to_i].push(ptm)
    end

    h_by_prot.each_key do |pid|
      list_ptm_ids = h_by_prot[pid].select{|ptm| ptm.status <= threshold}.map{|ptm| ptm.description.split('; ').first}.uniq.sort
      #logger.debug pid.to_json                                                                                                                                                                                               
      list_of_items = [list_ptm_ids]
      if params[:uniq]=='1'
        list_of_items = list_ptm_ids.map{|e| [e]}
      end
      list_of_items.each do |item|
        @h_res[item]||={
          :nber_all_prot => 0, 
          :nber_tm_prot => 0, 
          :nber_palm_tm_prot => 0, 
          :nber_palm_prot => 0, 
          :nber_palm_prot_ortho => 0, 
          :nber_palm_predicted_prot => 0
        }
        @h_res[item][:nber_all_prot]+=1
         
        @h_res[item][:nber_tm_prot]+=1 if h_tm_prots[pid]        
        if h_proteins[pid]
          @h_res[item][:nber_palm_prot]+=1 if h_proteins[pid].has_hits_public == true
          @h_res[item][:nber_palm_tm_prot]+=1 if h_proteins[pid].has_hits_public == true and  h_tm_prots[pid]
          @h_res[item][:nber_palm_prot_ortho]+=1 if h_proteins[pid].has_hits_ortho_public == true
          @h_res[item][:nber_palm_predicted_prot]+=1 if h_proteins[pid].has_hc_pred == true
        end
      end
    end

     respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'ptm_stats'}
      else
        format.html # index.html.erb                                                                                                                                                                                          
        format.text { render text: ["PTM", "Total number of proteins", "Number of palmitoylated proteins", "% of palmitoylated proteins", "Number of proteins predicted to be palmitoylated", "% of proteins predicted to be palmitoylated"].join("\t") + "\n" +
          @h_res.keys.map{|item|
            [item,
             @h_res[item][:nber_all_prot],
            @h_res[item][:nber_palm_prot],
            (@h_res[item][:nber_palm_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_prot_ortho],
             (@h_res[item][:nber_palm_prot_ortho].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_predicted_prot],
             (@h_res[item][:nber_palm_predicted_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_tm_prot],
             @h_res[item][:nber_palm_tm_prot],
             (@h_res[item][:nber_palm_tm_prot].to_f * 100 /  @h_res[item][:nber_tm_prot]).to_i
            ].join("\t")
          }.join("\n")
        }
        format.json { render json: @organism }
      end
    end
  end

  def subcell_location_stats
 
    params[:status]||=0
    threshold = params[:status].to_i
    @organism = Organism.find(params[:ref_organism_id])
    @dataset = params[:dataset]

    h_proteins = {}
    h_isoforms= {}
    h_predictions = {}

    h_cond = {:organism_id => @organism.id}
    h_cond[:validated_dataset] = true if @dataset == 'validated'

    Protein.find(:all, :conditions => h_cond).each do |p|
      h_proteins[p.id]=p
      h_predictions[p.id]=0
    end
   
    @h_sl={}
    SubcellularLocation.all.each do |sl|
      @h_sl[sl.id]=sl
    end
    
    @h_res = {}
    @h_res2 = {
      :nber_palm_prot => h_proteins.keys.select{|p| h_proteins[p].has_hits_public == true}.size,
      :nber_palm_prot_ortho => h_proteins.keys.select{|p| h_proteins[p].has_hits_ortho_public == true}.size,
      :nber_palm_prot_pred =>  h_proteins.keys.select{|p| h_proteins[p].has_hc_pred == true}.size
    }

    @subcellular_locations_proteins = SubcellularLocation.find(:all, :select => 'protein_id, subcellular_locations.*' ,:joins => 'join proteins_subcellular_locations on (subcellular_locations.id = subcellular_location_id) join proteins on (proteins.id = protein_id)', :conditions => {:proteins => {:organism_id => @organism.id}})
    
    h_by_prot = {}

    @subcellular_locations_proteins.each do |sl|
      h_by_prot[sl.protein_id.to_i]||=[]
      h_by_prot[sl.protein_id.to_i].push(sl)
    end

    h_by_prot.each_key do |pid|
      list_sl_ids = h_by_prot[pid].select{|sl| (sl.status) ? sl.status <= threshold : true}.map{|sl| @h_sl[sl.id].name}.uniq.sort
      #logger.debug pid.to_json
      list_of_items = [list_sl_ids]
      if params[:uniq]=='1'
        list_of_items = list_sl_ids.map{|e| [e]}
      end
      list_of_items.each do |item|
        @h_res[item]||={:nber_all_prot => 0, :nber_palm_prot => 0, :nber_palm_prot_ortho => 0, :nber_palm_predicted_prot => 0}
        @h_res[item][:nber_all_prot]+=1      
        if h_proteins[pid]
          @h_res[item][:nber_palm_prot]+=1 if h_proteins[pid].has_hits_public == true or h_proteins[pid].has_hits_targeted == true
          @h_res[item][:nber_palm_prot_ortho]+=1 if h_proteins[pid].has_hits_ortho_public == true
          @h_res[item][:nber_palm_predicted_prot]+=1 if h_proteins[pid].has_hc_pred == true
        end
      end
    end

     respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'subcell_location_stats'}
      else
        format.html # index.html.erb
        format.text { render text: ["Subcellular locations", "Total number of proteins", "Number of palmitoylated proteins", "% of palmitoylated proteins", "Number of palmitoylated proteins across all palmitomes", "% of palmitoylated proteins across all palmitomes", "Number of proteins predicted to be palmitoylated", "% of proteins predicted to be palmitoylated"].join("\t") + "\n" + 
          @h_res.keys.map{|item|
            [item,
             @h_res[item][:nber_all_prot],
            @h_res[item][:nber_palm_prot],
            (@h_res[item][:nber_palm_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_prot_ortho],
             (@h_res[item][:nber_palm_prot_ortho].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i,
             @h_res[item][:nber_palm_predicted_prot],
             (@h_res[item][:nber_palm_predicted_prot].to_f * 100 /  @h_res[item][:nber_all_prot]).to_i
            ].join("\t")
          }.join("\n")
        } 
        format.json { render json: @organism }
      end
    end
    

  end

  def cys_topo_stats
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @dataset = params[:dataset]
    
    @topologies = []
    @h_topo = {}
    @organisms.each do |o|
#      h =  JSON.parse(o.topo_json)
      h =(@dataset == 'validated') ? JSON.parse(o.topo_json_val) : JSON.parse(o.topo_json)
      @h_topo[o.id]={:pred => {}, :all => {}}
      h['all_cys'].keys.map{|k|
        @h_topo[o.id][:all][k]=h['all_cys'][k]
        @topologies.push(k) if !@topologies.include?(k)
      }
      h['nber_predicted_cys'].keys.map{|k|
        @h_topo[o.id][:pred][k]=h['nber_predicted_cys'][k]
        @topologies.push(k) if !@topologies.include?(k)
      }
    end
    
    respond_to do |format|
      format.html # index.html.erb        
      format.json { render json: @organisms }
    end
  end
  
  def cys_stats
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @dataset = params[:dataset]
    respond_to do |format|
      format.html # index.html.erb                                                                       
      format.json { render json: @organisms }
    end
  end

  def prot_stats
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @dataset = params[:dataset]
    h_proteins = {}
    Protein.all.map{|p| h_proteins[p.id]=p}
    #    targeted_studies = Study.find(:all, :conditions => {:large_scale => false})
    #    palmitome_studies = Study.find(:all, :conditions => {:large_scale => true, :hidden => false})
    h_studies = {}
    #    (targeted_studies & palmitome_studies)
    Study.all.map{|e| h_studies[e.id]=e}

    @h_palmitome = {}
    @h_annotated = {}

    Organism.all.each do |o|
      @h_palmitome[o.id]={}
      @h_annotated[o.id]={}
   end

    Hit.all.select{|h| h_proteins[h.protein_id]}.each do |h|
      if h_studies[h.study_id].large_scale == true and h_studies[h.study_id].hidden == false
        @h_palmitome[h_proteins[h.protein_id].organism_id]||={}
        @h_palmitome[h_proteins[h.protein_id].organism_id][h.protein_id]=1
      end
      if h_studies[h.study_id].large_scale == false
        @h_annotated[h_proteins[h.protein_id].organism_id]||={}
        @h_annotated[h_proteins[h.protein_id].organism_id][h.protein_id]=1
      end
    end

    respond_to do |format|
      format.html # index.html.erb    
      format.json { render json: @organisms }
    end

  end

  # GET /organisms
  # GET /organisms.json
  def index
    @organisms = Organism.find(:all, :conditions => {:has_proteins => true})
    @dataset = params[:dataset]
    proteins = Protein.find(:all, :conditions => {:has_hits_public => true})
    @h_proteins = {}
    proteins.map{|p| @h_proteins[p.id]=p}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisms }
    end
  end
  
  def go_term_summary
    
    params[:dataset] ||= 'all'
    params[:enrichment] ||= 30
    [:enrichment, :nber_prot, :ease_score].each do |e|
      params[e]=params[e].to_f
    end
    @dataset = params[:dataset]
    @organism = Organism.find(params[:id])

    @go_term_enrichments = GoTermEnrichment.find(:all, :conditions =>  ["organism_id = ? and nber_palm > ? and enrichment > ? and pval < ? and validated_dataset = ?", @organism.id, params[:nber_prot], params[:enrichment]/100, params[:ease_score], (params[:dataset] == 'validated') ? true : false
                                                                       ], :limit => 1000, :order  => 'pval' )

    respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'go_term_summary'}
      else
        format.html # show.html.erb                                                                                                                     
        format.text { render :text => @go_term_enrichments.map{|e| [e.go_term.acc, e.go_term.name, e.nber_palm, e.enrichment, e.pval].join("\t")}.join("\n")}
      end
    end
  end

  # GET /organisms/1
  # GET /organisms/1.json
  
  def palmitome_comparison

    helper = ApplicationController.helpers
    
    session[:studies]||= []

    @organism = Organism.find(params[:id])
    @h_hits={}

    @h_studies = {}   
    @h_cell_types = {}

    @all_studies = Study.find(:all, :conditions => {:large_scale => true, :organism_id => @organism.id}).select{|e| e.large_scale}.map{|e| @h_cell_types[e.cell_type_id] = e.cell_type; e}.sort{|a, b| [a.cell_type.name, a] <=> [b.cell_type.name, b]}
    session[:studies].delete_if{|e| !@all_studies.map{|e2| e2.id}.include?(e)}

    ### reject studies that are hidden
    @all_studies.reject!{|e| e.hidden == true} if !lab_user? and !admin?

    @studies = []
    if session[:studies].size > 0
      @studies = Study.find(:all, :conditions => {:large_scale => true, :organism_id => @organism.id, :id => session[:studies]})
      #      @studies = Study.find(session[:studies])
    else
      @studies = Study.find(:all, :conditions => {:large_scale => true, :organism_id => @organism.id})
    end
    @studies= @studies.select{|e| e.large_scale}.map{|e| @h_cell_types[e.cell_type_id] = e.cell_type; e}.sort{|a, b| [a.cell_type.name, a] <=> [b.cell_type.name, b]}

    if !params[:nber_studies] or params[:nber_studies].to_i > @studies.size
      params[:nber_studies] = (@studies.size * 0.7).to_i
    end

    @h_study_by_prot={}
    @h_cell_types.keys.map{|e| @h_studies[e]=[]}
    @all_studies.map{|s|  
      @h_studies[s.cell_type_id].push(s)
    }
    @studies.map{|s|
      @h_hits[s.id]={};
    }
 
    hits=Hit.find(:all, :joins => 'join proteins on (proteins.id = hits.protein_id)', :conditions => #[" nber_studies >= ? and 
                  ["proteins.organism_id = ? and hits.study_id in (?)", @organism.id, @studies.map{|s| s.id}]) # {:proteins => {:organism_id =>  @organism.id}})
    
    hits.select{|h| @h_hits[h.study_id]}.map{|h|
      @h_study_by_prot[h.protein_id]||={}
      @h_study_by_prot[h.protein_id][h.study_id]=1; 
      @h_hits[h.study_id][h.protein_id]||=[]; 
      @h_hits[h.study_id][h.protein_id].push(h)
    }
    @proteins = Protein.find(hits.map{|h| h.protein_id}).uniq.select{|e| @h_study_by_prot[e.id].keys.size>params[:nber_studies].to_i-1 }

    @annotated_hits = Hit.find(:all, :conditions => {:protein_id => @proteins.map{|e| e.id}, :hit_list_id => nil})
    @annotated_sites = Site.find(:all, :conditions => {:hit_id => @annotated_hits.map{|e| e.id}})

    respond_to do |format|
      if params[:partial]
        format.html { render :partial => 'palmitome_comparison'}
      else 
        format.html # show.html.erb
      end
   
      format.text { render text: 
        ['UniProt AC', 'UniProt ID', 'Description', 'Gene names', @studies.map{|e| helper.format_study_name(e)}, "# of studies"].flatten.join("\t") + "\n" + 
        @proteins.map{|e|
          hit_list=[]
          @studies.each do |study|
            if (@h_hits[study.id][e.id])
              hits = @h_hits[study.id][e.id]
              hit_list.push( hits.map{ |h|
                               hl = h.hit_list
                               (hl) ? (
                                       (hl.confidence_level) ? hl.confidence_level.tag : ((hl.label!= '') ? hl.label : 'Yes')
                                       ) : 'Paper'
                             }.join(", "))
            else 
              hit_list.push('-')
            end
          end
          
          [e.up_ac, e.up_id, e.description, e.ref_proteins.select{|e| e.source_type and e.source_type.name == 'gene_name'}.map{|e| e.value}.join(', '),
           hit_list, @h_study_by_prot[e.id].keys.size
          ].flatten.join("\t")
        }.join("\n")}
      format.json { render json: @organism }
    end
  end

  def show
    @organism = Organism.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb                                                                                                                                         
      format.json { render json: @page }
    end
    
  end

  # GET /organisms/new
  # GET /organisms/new.json
  def new
    @organism = Organism.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end

  # POST /organisms
  # POST /organisms.json
  def create
    @organism = Organism.new(params[:organism])

    respond_to do |format|
      if @organism.save
        format.html { redirect_to @organism, notice: 'Organism was successfully created.' }
        format.json { render json: @organism, status: :created, location: @organism }
      else
        format.html { render action: "new" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(params[:organism])
        format.html { redirect_to organisms_path, notice: "Organism #{@organism.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisms/1
  # DELETE /organisms/1.json
  def destroy
    @organism = Organism.find(params[:id])
    @organism.destroy

    respond_to do |format|
      format.html { redirect_to organisms_url }
      format.json { head :no_content }
    end
  end
end
