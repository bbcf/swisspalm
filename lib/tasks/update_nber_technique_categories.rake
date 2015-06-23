namespace :swisspalm do

  desc "Update nber technique categories"
  task :update_nber_technique_categories, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    h_studies = {}
    Study.all.map{|s| h_studies[s.id]=s}
    
    proteins = Protein.all
    h_proteins = {}
    proteins.map{|p| h_proteins[p.id] = p}
   
    hits = Hit.find(:all, :conditions => {:protein_id => proteins.map{|p| p.id}})
    h_hits_by_pid= {}
    hits.map{|h| h_hits_by_pid[h.protein_id]||=[]; h_hits_by_pid[h.protein_id].push(h)}
    
    h_proteins.each_key do |pid|
      
      if h_hits_by_pid[pid]
        #      puts pid
        studies = h_hits_by_pid[pid].map{|h| h_studies[h.study_id]}.uniq
        studies_public = h_hits_by_pid[pid].select{|h| h_studies[h.study_id].hidden == false}.map{|h| h_studies[h.study_id]}.uniq
        
        h_proteins[pid].update_attribute(:nber_technique_categories_labuser, studies.select{|s| s.large_scale}.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size)
        h_proteins[pid].update_attribute(:nber_technique_categories_public, studies_public.select{|s| s.large_scale}.map{|s| s.techniques.map{|e| e.technique_category}.compact}.flatten.uniq.size)
      else
        h_proteins[pid].update_attribute(:nber_technique_categories_labuser,0)
        h_proteins[pid].update_attribute(:nber_technique_categories_public, 0)
      end
    end
  end
end
