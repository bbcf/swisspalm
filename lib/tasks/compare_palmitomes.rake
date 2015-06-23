namespace :swisspalm do

  desc "Compare palmitomes"
  task :compare_palmitomes, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include Compare

    `psql -c 'drop table old_palmitome_entries' swisspalm`
    `psql -c 'create table tmp_palmitome_entries(id serial, organism_id int references organisms,protein_id int references proteins, hit_list_json text, orthologue_protein_ids text, nber_palmitome_studies int, palmitome_study_ids text, targeted_study_ids text, targeted_study_ids_prot text, targeted_study_protein_ids text, technique_ids text, annotated_site_ids text, primary key (id))' swisspalm`
    
    sel_study_ids = Study.find(:all, :conditions => {:large_scale => true})
    
    Organism.all.each do |o|
      results = compare_palmitomes(o.id, sel_study_ids)   
      puts o.name + ": " + results.size.to_s
      
      results.each do |h| 
        
        h_pe={
          :organism_id => o.id, 
          :protein_id => h[:protein].id, 
          :hit_list_json => h[:hit_list].to_json,
          :nber_palmitome_studies => h[:nber_palmitome_studies]
        }
        
        [:orthologue_protein_ids, :palmitome_study_ids, :targeted_study_ids, :targeted_study_ids_prot,  :targeted_study_protein_ids, :technique_ids, :annotated_site_ids].each do |e|
          h_pe[e]=h[e].join(",")
        end
        
        pe = TmpPalmitomeEntry.new(h_pe)
        pe.save
      end
    end
  
    ### index
    `psql -c 'create index tmp_palmitome_entries_organism_id_nber_palmitome_studies_idx on tmp_palmitome_entries(organism_id, nber_palmitome_studies);`
    
    ### switch
    `psql -c 'drop table old_palmitome_entries' swisspalm`
    `psql -c 'alter table palmitome_entries rename to old_palmitome_entries' swisspalm`
    `psql -c 'alter table tmp_palmitome_entries rename to palmitome_entries' swisspalm`
    
    ### rename index
    `psql -c 'ALTER INDEX tmp_palmitome_entries_organism_id_nber_palmitome_studies_idx RENAME TO palmitome_entries_organism_id_nber_palmitome_studies_idx' swisspalm`




    ### set has_hits_ortho_public # nothing related to palmitome_entries

    `psql -c 'update proteins set has_hits_ortho_public = false' swisspalm`
    
    h_studies = {}
    Study.all.map{|s| h_studies[s.id] = s}
    
    Protein.all.each do |p|
      flag =0
      pe = PalmitomeEntry.find(:all, :conditions => {:protein_id => p.id})
      study_ids = []
      pe.each do |e|	
        study_ids.push(e.palmitome_study_ids.split(",") + e.targeted_study_ids.split(","))        
      end
      if study_ids.flatten.uniq.select{|sid|  h_studies[sid.to_i].hidden != true}.size > 0
        p.update_attribute(:has_hits_ortho_public, true)
      end
    end

  end
end
