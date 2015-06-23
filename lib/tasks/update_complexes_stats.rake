namespace :swisspalm do
  
  desc "Update complexes stats"
  task :update_complexes_stats, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    include Compare

    ProteinComplex.all.each do |pc|
    
      proteins = pc.proteins

      if proteins.size > 0
        
        h = {
          :organism_id => proteins.first.organism_id,
          :nber_prot => proteins.size,
          :nber_prot_with_c => proteins.select{|p| p.nber_cys_max > 0}.size,
          :nber_prot_predicted => proteins.select{|p| p.has_hc_pred_valid == true}.size,
          :nber_prot_palm => proteins.select{|p| p.has_hits == true}.size,
          :nber_prot_validated_dataset => proteins.select{|p| p.validated_dataset == true}.size
        }	
        #	puts h.to_json      
        pc.update_attributes(h)
        
      end
    end
    
  end
end
