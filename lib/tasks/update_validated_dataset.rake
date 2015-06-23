namespace :swisspalm do

  desc "Update validated dataset"
  task :update_validated_dataset, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
  include Compare

    h_studies = {}
    Study.all.map{|s| h_studies[s.id]=s}

    
    h_technique_category_ids_by_technique_id = {}
    Technique.all.map{|t|
      h_technique_category_ids_by_technique_id[t.id] = t.technique_category_id
    }
    

    o = Organism.find_by_name('Homo sapiens')
#    Organism.all.each do |o|
#      sel_study_ids = Study.find(:all, :conditions => {:organism_id => o.id, :large_scale => true, :hidden => false})
    #  results = compare_palmitomes(o.id, sel_study_ids)
    #puts o.name + ": " + results.size.to_s
    h_gene_names={}
    Protein.find(:all, :conditions => ["nber_technique_categories_public > 1 or has_hits_targeted is true"], :order => 'trembl desc').each do |p|
      # results.each do |h|
      
      #      h_pe={
      #        :organism_id => o.id,
      #        :protein_id => h[:protein].id,
      #        :hit_list_json => h[:hit_list].to_json,
      #        :nber_palmitome_studies => h[:nber_palmitome_studies]
      #      }
      #      
      #      [:orthologue_protein_ids, :palmitome_study_ids, :targeted_study_ids, :targeted_study_ids_prot,  :targeted_study_protein_ids, :technique_ids, :annotated_site_ids].each do |e|
      #        h_pe[e]=h[e].join(",")
      #      end
      
      #        nber_cat_tech = h[:technique_ids].map{|tid| h_technique_category_ids_by_technique_id[tid]}.uniq.compact.size 
       # if nber_cat_tech == 2 or h[:targeted_study_ids].select{|sid| h_studies[sid].organism_id == o.id and h_studies[sid].hidden == false}.compact.size > 0 and h[:protein].organism_id == o.id
      gene_names = p.ref_proteins.select{|rp| rp.source_type and rp.source_type.name == 'gene_name' }.map{|e| e.value}.sort
      flag = 0
      gene_names.each do |gn|
        flag = 1 if h_gene_names[gn]	
      end
      if flag==0 or p.trembl == false
	gene_names.each do |gn|
          h_gene_names[gn]==1
        end
        if p.up_ac == 'O95166'
       #   puts h[:technique_ids].uniq.to_yaml
       #   puts h[:technique_ids].map{|tid| h_technique_category_ids_by_technique_id[tid]}.uniq.to_yaml
       #   puts h[:targeted_study_ids].select{|sid| h_studies[sid].organism_id == o.id and h_studies[sid].hidden == false}.to_yaml
        end
        p.update_attribute(:validated_dataset, true)
      end
        
      end
#    end 
    
  end
end
