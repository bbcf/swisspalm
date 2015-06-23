namespace :swisspalm do

  desc "Compute InterPro summary"
  task :compute_interpro_summary, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'nokogiri'
    include LoadData

    puts "get proteins..."

    h_proteins = {}
    Protein.all.each do |p|
      h_proteins[p.id]=p
    end

    puts "compute nber prot by interpro..." 

    h_nber_prots_by_interpro={}
    h_interpro = {}
    
    InterproMatch.all.each do |m|
      h_nber_prots_by_interpro[m.interpro_id]||={}
      h_nber_prots_by_interpro[m.interpro_id][h_proteins[m.protein_id].organism_id]||=0
      h_nber_prots_by_interpro[m.interpro_id][h_proteins[m.protein_id].organism_id]+=1
      h_interpro[m.interpro_id]=m
    end

    puts "update numbers in database..."
    
    h_nber_prots_by_interpro.each_key do |interpro_id|
      interpro = Interpro.find(:first, :conditions => {:id => interpro_id})
      
      if !interpro
        interpro = Interpro.new({
                                  :id => interpro_id,
                                  :description => h_interpro[interpro_id].description,
                                  :nber_proteins => h_nber_prots_by_interpro[interpro_id].to_json
                                })
        interpro.save
      else
        interpro.update_attributes({
                          :description =>  h_interpro[interpro_id].description, 
                          :nber_proteins => h_nber_prots_by_interpro[interpro_id].to_json                          
                        })
      end
    end
  end  
end


