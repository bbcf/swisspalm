namespace :swisspalm do

  desc "Compute ss stats"
  task :compute_ss_stats, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    
    
    all_sites = Site.all

    isoforms = Isoform.find(:all, :conditions => {:protein_id => all_sites.map{|s| s.hit.protein_id}})
    h_isoforms = {}
    isoforms.map{|i| h_isoforms[i.id]=i}



    count_sites_with_ss = 0
    count_sites_without_ss = []
    c = 0
    # puts h_isoforms.to_json
    
    h_sites_by_ss = {1 => [], 2=> [], 3 => []}
    h_sites_by_ss2 = {1 => 0, 2=> 0, 3 => 0}

    
    all_sites.each do |s|
      hit = s.hit
      isoform_id = hit.isoform_id
      isoform_id ||= Protein.find(hit.protein_id).isoforms.select{|e| e.main}.first.id 
      #	puts h_isoforms.to_json   
      if h_isoforms[isoform_id] and h_isoforms[isoform_id].main == true
        #        puts 'toto'
        pred = Prediction.find(:first, :conditions => {:isoform_id => isoform_id, :pos => s.pos})
        if pred	
          if pred.psipred_ss
            count_sites_with_ss +=1
            h_sites_by_ss[pred.psipred_ss].push(h_isoforms[isoform_id].protein_id)
             h_sites_by_ss2[pred.psipred_ss]+=1
          else
            count_sites_without_ss.push([isoform_id, s.pos])
          end
        else	
          puts isoform_id.to_s + " - " + s.pos.to_s 
          c +=1
        end
      end
    end
    
    puts c
    puts count_sites_with_ss
    puts count_sites_without_ss.to_json
    
    h_sites_by_ss.each_key do |ss|
      h_sites_by_ss[ss].uniq!
      puts "ss #{ss}: nber of proteins #{h_sites_by_ss[ss].size}"
      puts "ss #{ss}: nber of sites #{h_sites_by_ss2[ss]}"
    end

    
    count_c_with_ss = 0
    count_c_without_ss = []
    c = 0
    # puts h_isoforms.to_json                                                                                                    

    h_c_by_ss = {1 => [], 2=> [], 3 => []}
    h_c_by_ss2 = {1 => 0, 2=> 0, 3 => 0}
    

    h_predictions = {}
    Prediction.all.each do |pred|
      h_predictions[pred.isoform_id]||=[]
      h_predictions[pred.isoform_id].push(pred)
    end
    
    
    Isoform.find(
                 :all, 
                 :joins => "join proteins on (proteins.id = protein_id)" , 
                 :conditions => {:proteins => {:organism_id => [1,2]}}).each do |isoform|

      #      hit = s.hit
#      isoform_id = hit.isoform_id
#      isoform_id ||= Protein.find(hit.protein_id).isoforms.select{|e| e.main}.first.id
      isoform_id = isoform.id
      # puts h_isoforms.to_json                                                                                                  
      if isoform.main == true and h_predictions[isoform_id]
        #        puts 'toto'                                                                                                     
#        Prediction.find(:all, :conditions => {:isoform_id => isoform_id}).each do |pred|
	
        h_predictions[isoform_id].each do |pred|
          if pred
            if pred.psipred_ss
              count_c_with_ss +=1
              h_c_by_ss[pred.psipred_ss].push(isoform.protein_id)
              h_c_by_ss2[pred.psipred_ss]+=1
            else
              count_c_without_ss.push([isoform_id, pred.pos])
            end
          else
            puts isoform_id.to_s + " - " + pred.pos.to_s
            c +=1
          end
        end
      end
    end

    puts "All cysteines:"
    h_c_by_ss.each_key do |ss|
      h_c_by_ss[ss].uniq!
      puts "ss #{ss}: nber of proteins #{h_c_by_ss[ss].size}"
      puts "ss #{ss}: nber of sites #{h_c_by_ss2[ss]}"
    end


  end
end
