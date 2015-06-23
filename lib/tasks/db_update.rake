namespace :swisspalm do

  desc "Database update"
  task :db_update, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

    ###
    puts "test"
    hits=Hit.find(:all, :joins => 'join proteins on (proteins.id = hits.protein_id)', :conditions => {:proteins => {:organism_id => 1}})
    puts "test finished"


    ###  update nber of studies by hit

    puts "Update nber of palmitome studies by protein..."
    Protein.find(:all, :conditions => {:has_hits => true}).each do |p|
      h_studies = {}	
      h_all_studies={}
      p.hits.select{|h| h.study and h.study.large_scale}.each do |h|	
	h_studies[h.study_id]=1 if h.study.hidden == false
        h_all_studies[h.study_id]=1
      end
      p.update_attributes({
                            :nber_all_studies => h_all_studies.keys.size, 
                            :nber_studies => h_studies.keys.size})
    end
    
  end
end


