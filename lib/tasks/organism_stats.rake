namespace :swisspalm do

  desc "Organism stats"
  task :organism_stats, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root}/config/environment"
    
    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include LoadData
    
    puts "get disulfide bond data..."

    h_features = {
        :feature_type_id => 6
    }
    all_disulfides = Feature.find(:all, :conditions => h_features)    
    h_all_topological_domains = {}
    Feature.find(:all, :conditions => {:feature_type_id => 2}, :order => 'start').select{|f| f.start}.map{|f|
        h_all_topological_domains[f.protein_id]||=[]
        h_all_topological_domains[f.protein_id].push(f)
    }

    puts "get extracellular location proteins..."

    h_subcellular_locations = {}
    SubcellularLocation.all.each do |sl|
      h_subcellular_locations[sl.id] = sl
    end
    
    h_subcell_prot={}
    SubcellularLocation.find(:all, :select => "protein_id, subcellular_location_id", :joins => "join proteins_subcellular_locations on (subcellular_locations.id = subcellular_location_id)").each do |e|
      h_subcell_prot[e.protein_id.to_i]||={}
      h_subcell_prot[e.protein_id.to_i][e.subcellular_location_id.to_i]=1
    end

    h_extracellular_prot = {}

    h_subcell_prot.each_key do |protein_id|
      if h_subcell_prot[protein_id].keys.reject{|sl_id| puts sl_id if !h_subcellular_locations[sl_id]; ['Extracellular', 'Lumenal'].include?(h_subcellular_locations[sl_id].name)}.size == 0 
        h_extracellular_prot[protein_id]=1
      end
    end

    puts "start main program..."
    

    def update1(o, all_disulfides, h_all_topological_domains, h_extracellular_prot, val)	

      suffix = (val == true) ? '_val' : ''
      
      proteins = o.proteins
      h_proteins = {}
      if val == true
        proteins.select!{|p| p.validated_dataset == true}
      end
      proteins.map{|p| h_proteins[p.id]=p}

      isoforms = Isoform.find(:all, :conditions => {:protein_id => proteins.map{|e| e.id} })
      h_isoforms={}
      isoforms.map{|i| h_isoforms[i.id]=i}
      predictions_main_isoform = Prediction.find(:all, :conditions => {:isoform_id => isoforms.select{|i| i.main == true}.map{|i| i.id}})

      disulfides = all_disulfides.select{|e| h_proteins[e.protein_id]}
      h_d = {}
      disulfides.map{|d| h_d[[d.protein_id, d.start]]=1; h_d[[d.protein_id, d.stop]]=1}

      predictions_hc =  predictions_main_isoform.select{|p| p.hc_pred == true } #p.cp_high_cutoff > 0}
      h_pred = {}
      predictions_main_isoform.sort{|a, b| a.pos <=> b.pos}.map{|e|
        h_pred[e.isoform_id]||=[]
        h_pred[e.isoform_id].push(e)
      }

      h_topo = {
        :all_cys => {},
        :nber_predicted_cys => {}
      }
      h_extracell_topo = {}

      h_topo[:all_cys]['Unknown']=0
      h_topo[:nber_predicted_cys]['Unknown']=0

      h_pred.each_key do |isoform_id|
        topo_doms = h_all_topological_domains[h_isoforms[isoform_id].protein_id]
	topo_doms.select!{|e| e.stop and e.start} if topo_doms
        if topo_doms and topo_doms.size > 0
          i=0
          h_pred[isoform_id].each do |pred|

#	puts ">" + pred.to_json if pred.pos == nil
#	puts ">>" + topo_doms[i].to_json if topo_doms[i].stop == nil

            while i < topo_doms.size and pred.pos > topo_doms[i].stop do
              i+=1
            end
            i-=1 if i == topo_doms.size
            if pred.pos >= topo_doms[i].start and pred.pos <= topo_doms[i].stop
              if pred.hc_pred == true #pred.cp_high_cutoff > 0
                h_topo[:nber_predicted_cys][topo_doms[i].description]||=0
                h_topo[:nber_predicted_cys][topo_doms[i].description]+=1
                if h_isoforms[isoform_id].main == true
                  h_extracell_topo[h_isoforms[isoform_id].protein_id]||={}
                  h_extracell_topo[h_isoforms[isoform_id].protein_id][pred.pos]=1
                end
              end
              h_topo[:all_cys][topo_doms[i].description]||=0
              h_topo[:all_cys][topo_doms[i].description]+=1
            else
              if pred.hc_pred == true #pred.cp_high_cutoff > 0
                h_topo[:nber_predicted_cys]['Unknown']+=1
              end
               h_topo[:all_cys]['Unknown']+=1
            end

          end
        else
        end
      end
      
      h={
        ('nber_cys_in_disulfides' + suffix).intern => h_d.keys.size,
        ('nber_cys_main_isoform' + suffix).intern => predictions_main_isoform.size,
        ('nber_predicted_cys_main_isoform' + suffix).intern => predictions_hc.size,
        ('nber_predicted_cys_in_disulfides_main_isoform' + suffix).intern => predictions_hc.select{|pred| h_d[[h_isoforms[pred.isoform_id].protein_id, pred.pos]]}.size,
        ('nber_proteins_with_predicted_cys_main_isoform' + suffix).intern => predictions_hc.map{|pred| h_isoforms[pred.isoform_id].protein_id}.uniq.size,
        ('nber_prot_with_predicted_cys_main_isoform_without_false_pos' + suffix).intern => predictions_hc.reject{|pred| (h_extracell_topo[h_isoforms[pred.isoform_id].protein_id] and h_extracell_topo[h_isoforms[pred.isoform_id].protein_id][pred.pos]) or h_d[[h_isoforms[pred.isoform_id].protein_id, pred.pos]]}.map{|pred| h_isoforms[pred.isoform_id].protein_id}.uniq.select{|pid| !h_extracellular_prot[pid]}.size,
        ('nber_proteins_with_disulfide' + suffix).intern => h_d.keys.map{|t| t[0]}.uniq.size,
        ('topo_json' + suffix).intern => h_topo.to_json
      }
      # puts h.to_json
      begin
        o.update_attributes(h)
      rescue Exception => e
        raise e.message
      end
        #      h.each_key do |k|
#        o.update_attribute(k, h[k])
#      end
      puts o.to_yaml
     
    end

    def update2(o, val)

      suffix = (val == true) ? '_val' : ''

      h_common = {}
      h_common_studies = {}
      h_diff = {}
      h_diff_studies = {}
      all_palmitome_studies =  Study.find(:all, :conditions => {:large_scale => true}).select{|e| e.hidden != true}
      palmitome_studies = Study.find(:all, :conditions => {:organism_id => o.id, :large_scale => true}).select{|e| e.hidden != true}
      h_palmitome_studies = {}
      all_palmitome_studies.map{|ps| h_palmitome_studies[ps.organism_id]||={}; h_palmitome_studies[ps.organism_id][ps.id]=1}
      h_proteins = {}
      h_validated = {}
      Protein.find(:all, :conditions => {:validated_dataset => true}).map{|p| h_validated[p.id]=1}
      proteins = o.proteins

      if val == true
        proteins.select!{|p| p.validated_dataset == true}
      end
      proteins.map{|p| h_proteins[p.id]=p}

      palmitome_studies.each do |ps1|

        #initialisation
        h_common_studies = {}
        h_diff_studies = {}
        hits = ps1.hits
        h_hits = {}
      #  puts ps1.to_json
      #  puts hits.to_json
        hits.select{|h| h_proteins[h.protein_id]}.map{|h| h_hits[h.protein_id]=1}
        palmitome_studies.each do |ps2|
          h_common_studies[ps2.id]={}
          h_diff_studies[ps2.id]={}
        end

        #comparison
        hits.each do |h|
          palmitome_studies.select{|ps2| ps2 != ps1}.each do |ps2|            
            ps2.hits.select{|h2| h_proteins[h2.protein_id]}.each do |h2| 
              if h_hits[h2.protein_id] and ps2 != ps1
                h_common_studies[ps2.id][h.protein_id]=1
              else
                h_diff_studies[ps2.id][h.protein_id]=1
              end
            end
          end
        end

        h_common_studies.each_key do |k|
          h_common_studies[k]=h_common_studies[k].keys
          h_diff_studies[k]=h_diff_studies[k].keys
        end
        
        ps1.update_attributes({
                                ('prot_common_in_palmitomes_json' + suffix).intern  => h_common_studies.to_json,
                                ('prot_diff_in_palmitomes_json' + suffix).intern => h_diff_studies.to_json 
                              })        
      end

      
      if h_palmitome_studies[o.id]

        Organism.all.select{|o2| h_palmitome_studies[o2.id]}.each do |o2|
          #      l = [o.id, o2.id].sort                                                                                                                                               
          h_common[o2.id]||={}
          h_diff[o2.id]||={}
          
          PalmitomeEntry.find(:all, :conditions => {:organism_id => o2.id}).each do |pe|
            if pe.palmitome_study_ids.split(',').select{|e| h_palmitome_studies[o.id][e.to_i]}.size > 0 and o2.id != o.id and (val == false or  h_validated[pe.protein_id])
              if pe.palmitome_study_ids.split(',').select{|e| h_palmitome_studies[o2.id][e.to_i]}.size > 0
                h_common[o2.id][pe.protein_id]=1
              else
                h_diff[o2.id][pe.protein_id]=1
              end
            end
          end
        end


        h_common.each_key do |k|
          h_common[k]=h_common[k].keys
          h_diff[k]=h_diff[k].keys
        end

      end

      #      puts h_common.to_json
      
      h={
        ('prot_common_in_palmitomes_json' + suffix).intern => h_common.to_json,
        ('prot_diff_in_palmitomes_json' + suffix).intern => h_diff.to_json
      }
      o.update_attributes(h)

    end

	
    Organism.all.each do |o|
      puts "=> " + o.name

#      puts "1"
#      update1(o, all_disulfides, h_all_topological_domains, h_extracellular_prot, false)
#      puts "2"
#      update1(o, all_disulfides, h_all_topological_domains, h_extracellular_prot, true)
      puts "3"
      update2(o, false)
      puts "4"
      update2(o, true)
      
    end

    
  end
end
