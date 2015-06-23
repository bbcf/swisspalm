namespace :swisspalm do

  desc "Load predictions"
  task :load_predictions, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    
    ### open file
    predictions_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'predictions'
    
    puts "get disulfide bond data..."
    
    h_features = {
      :feature_type_id => 6
    }
    all_disulfides = Feature.find(:all, :conditions => h_features)
    h_all_topological_domains = {}
    Feature.find(:all, :conditions => {:feature_type_id => 2#, :protein_id => 62187
                 }, :order => 'start').map{|f|
      if f.start and f.stop
        h_all_topological_domains[f.protein_id]||=[]
        h_all_topological_domains[f.protein_id].push(f)
      end
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
      if h_subcell_prot[protein_id].keys.reject{|sl_id| 
          puts sl_id if !h_subcellular_locations[sl_id]
          ['Extracellular', 'Lumenal'].include?(h_subcellular_locations[sl_id].name)}.size == 0
        h_extracellular_prot[protein_id]=1
      end
    end

    
    proteins = Protein.all#.select{|p| p.id==62187}
    h_proteins = {}
    proteins.map{|p| h_proteins[p.id]=p}
    
    isoforms = Isoform.find(:all) # ,conditions => {:protein_id => proteins.map{|e| e.id} })
    h_isoforms={}
    isoforms.map{|i| h_isoforms[i.id]=i}
  #  predictions_main_isoform = Prediction.find(:all, :conditions => {:isoform_id => isoforms.select{|i| i.main == true}.map{|i| i.id}})
    
    disulfides = all_disulfides.select{|e| h_proteins[e.protein_id]}
    h_d = {}
    disulfides.map{|d| h_d[[d.protein_id, d.start]]=1; h_d[[d.protein_id, d.stop]]=1}
    
  #  predictions_hc =  predictions_main_isoform.select{|p| p.cp_high_cutoff > 0}
    
    
    puts "read csspalm predictions..."
    
    
    res = {'pp_score' => {}, 'palmpred' => {}, 'psipred_ss' => {}, 'uniprot_ss' => {}}
    
    ['high', 'medium', 'low'].each do |level|
      puts "reading #{level}..."
      
      res['cp_' + level + '_cutoff']={}
        
      File.open(predictions_dir + ('csspalm_results_' + level + '.tab'), 'r') do |f|
        while l = f.gets do
          l.chomp!
          tab = l.split("\t")
            id = tab[0].split("|")[0].to_i
          pos = tab[1].to_i
          
          res['cp_' + level + '_cutoff'][id]||={}
          res['cp_' + level + '_cutoff'][id][pos]=tab[4].to_f
        end
      end
      
    end

    puts "read PalmPred predictions..."
    
    File.open(predictions_dir + 'PalmPred' + 'all_prediction', 'r') do |f|
      while l = f.gets do
        l.chomp!
        #>102423:RSKRLCPTIAT:27:-1.0231613:0
        tab = l.split(":")
        isoform_id = tab[0].split(">").last.to_i
        pos = tab[2].to_i
        score = tab[3].to_f
        #        prediction = Prediction.find(:first, :conditions => {:isoform_id => isoform_id, :pos => pos})
        res['pp_score'][isoform_id]||={}
        res['pp_score'][isoform_id][pos]=score
        
        #res['palmpred'][isoform_id][pos]= (score > 0.4) ? true : false 
      end
    end

    puts "extract secondary structure annotation from uniprot..."

    h_features = {}
    Feature.find(:all, :conditions => {:feature_type_id => [19, 20, 21]}).each do |feature|
      h_features[feature.protein_id]||=[]
      h_features[feature.protein_id].push(feature)
    end
    
    

    puts "read secondary structure predictions..."

#   1 M C   0.999  0.000  0.001
#   2 K C   0.781  0.006  0.324
#   3 A C   0.801  0.004  0.374
#   4 F E   0.418  0.028  0.656

    h_ss = {'H' => 1, 'E' => 2, 'C' => 3}
    h_uniprot_ss = {
      19 => 1, #helix
      20 => 2, #strand 
      21 => 3 #turn
    }
    
    ss_dir = Dir.new(Pathname.new(APP_CONFIG[:data_dir]) + 'ss' + 'psipred' + 'ss')
    ss_dir.entries.reject{|e| e.match(/^\./)}.each do |filename|      
      if m = filename.match(/(\d+)\.ss/) and h_isoforms[m[1].to_i]
        id = m[1].to_i
        res['psipred_ss'][id]={}
        h_tmp_pos = {}
	#puts id

        list_pos = []
        puts id if !h_isoforms[id] or !h_isoforms[id].seq
        tmp = h_isoforms[id].seq.split('')
        tmp.each_index do |i|
          list_pos.push(i+1) if tmp[i] == 'C'
        end
        
        list_pos.map{|p| h_tmp_pos[p]=1} #if res['cp_low_cutoff'][id]
        File.open(Pathname.new(APP_CONFIG[:data_dir]) + 'ss' + 'psipred' + 'ss' + filename, 'r') do |f|
          while (l = f.gets) do
            tab = l.strip.split(/\s+/)
            pos = tab[0].to_i
            ss = h_ss[tab[2]]
            aa = tab[1]
            if aa == 'C' 
              res['psipred_ss'][id][pos]=ss
            end
          end
       end
      end
    end

    puts "compute compability regarding to subcell loc / topology..."
    
    h_extracell_topo = {}
    
    h_isoforms.each_key do |isoform_id|
      if h_isoforms[isoform_id].main == true 
        
        topo_doms = h_all_topological_domains[h_isoforms[isoform_id].protein_id]
        #   puts topo_doms.to_json
        if topo_doms and topo_doms.size > 0
          i=0
          list_pos = []
          tmp = h_isoforms[isoform_id].seq.split('')
          tmp.each_index do |i|
           list_pos.push(i+1) if tmp[i] == 'C'
          end
          list_pos.each do |pos|
            
            while i < topo_doms.size and pos > topo_doms[i].stop do
              i+=1
            end
            i-=1 if i == topo_doms.size
            if pos >= topo_doms[i].start and pos <= topo_doms[i].stop
    #          puts pos
              # if res['cp_high_cutoff'][isoform_id][pos] > 0
              # h_topo[:nber_predicted_cys][topo_doms[i].description]||=0
              # h_topo[:nber_predicted_cys][topo_doms[i].description]+=1
              if ['Lumenal', 'Extracellular'].include?(topo_doms[i].description)
                h_extracell_topo[h_isoforms[isoform_id].protein_id]||={}
                h_extracell_topo[h_isoforms[isoform_id].protein_id][pos]=1
              end
              #  end
              #  h_topo[:all_cys][topo_doms[i].description]||=0
              #  h_topo[:all_cys][topo_doms[i].description]+=1
              # else
              #   if pred.cp_high_cutoff > 0
              #     h_topo[:nber_predicted_cys]['Unknown']+=1
              #   end
              #   h_topo[:all_cys]['Unknown']+=1
              # end
              
            end
          end
        else
        end
      else
        #        puts isoform_id
      end
    end

#puts h_extracell_topo.to_json

#exit
    
    puts "creating predictions..."    
    File.open(predictions_dir + 'csspalm_results_all.tab') do |f|
      while l = f.gets do
        l.chomp!
        tab = l.split("\t")
        id = tab[0].split("|")[0].to_i
	isoform = h_isoforms[id]
	if isoform	
          protein_id = h_isoforms[id].protein_id
          pos = tab[1].to_i
          if id != 0
            uniprot_ss=nil
            features = h_features[protein_id]
            if features
              features.sort{|a, b| a.start <=> b.start}.each do |feature|
                if pos >= feature.start and pos <= feature.stop
                  uniprot_ss = h_uniprot_ss[feature.feature_type_id] 
                  break
                end
              end
            end
            
            h_prediction = {
              :isoform_id => id,
              :pos => pos,
              :cp_score => tab[3].to_f,
              :cp_high_cutoff => (res['cp_high_cutoff'][id] and res['cp_high_cutoff'][id][pos]) ? res['cp_high_cutoff'][id][pos] : 0,
              :cp_medium_cutoff => (res['cp_medium_cutoff'][id] and res['cp_medium_cutoff'][id][pos]) ? res['cp_medium_cutoff'][id][pos] : 0,
              :cp_low_cutoff => (res['cp_low_cutoff'][id] and res['cp_low_cutoff'][id][pos]) ? res['cp_low_cutoff'][id][pos] : 0,
              :cp_all_cutoff => tab[4].to_f,
              :palmpred => (res['pp_score'][id] and res['pp_score'][id][pos] and res['pp_score'][id][pos] > 0.4) ? true : false,            
              :psipred_ss => (res['psipred_ss'][id]) ? res['psipred_ss'][id][pos] : nil,
            :uniprot_ss => uniprot_ss,
              :pp_score => (res['pp_score'][id] and res['pp_score'][id][pos]) ? res['pp_score'][id][pos] : nil,
              :compatible_loc => (h_extracellular_prot[h_isoforms[id].protein_id] or 
                                  (h_extracell_topo[h_isoforms[id].protein_id] and h_extracell_topo[h_isoforms[id].protein_id][pos]) or 
                                  h_d[[h_isoforms[id].protein_id, pos]]) ? false : true
            }
            #  puts h_prediction.to_json
            prediction = Prediction.new(h_prediction) 
            prediction.save
          end
        end
      end

    end
    
    

   
    
  end
end
