namespace :swisspalm do

  desc "Load UniProt features"
  task :load_features, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'

    include LoadData



    def load_protein_features(organism, h_feature_types)
      
      dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
      files = ["#{organism.taxid}.all.xml", "#{organism.taxid}_db_update_entries.xml"].reverse
      
      res = {}

      h_statuses = {
        'by similarity' => 1,
        'potential' => 3,
        'probable' =>2
      }
      
      files.each do |file|
        
        filepath_xml = dir + file
        if File.exists?(filepath_xml)
          puts "read #{filepath_xml}..."
          
          doc = open(filepath_xml) { |f| Hpricot(f) }
          doc.search("entry").each do |entry|
            trembl = (entry['dataset'] == 'Swiss-Prot') ? false : true
            accessions = entry.search("accession")
            up_ac = accessions.first.innerHTML
            protein = Protein.find_by_up_ac(up_ac)
            if protein
              #          res[protein.id]=[]
              #          puts "-> " + up_ac                                                                                                                                                                                
              
              entry.search("feature").each do |feature|
                if h_feature_types[feature['type']] and location = feature.at("location")
                  start = (location.at("begin")) ? location.at("begin")['position'] : location.at("position")['position']
                  stop = (location.at("end")) ? location.at("end")['position'] : location.at("position")['position']
                  #              puts up_ac + ": " + [start, stop].join(", ")                                                                                                                                                  
                  
                  h_feature = {
                    :feature_type_id => h_feature_types[feature['type']].id,
                    :protein_id => protein.id,
                    :start => start,
                    :stop => stop,
                    :original =>  (ori = feature.at("original")) ? ori.innerHTML : nil,
                    :variation => (variation = feature.at("variation")) ? variation.innerHTML : nil,
                    :description => feature['description'],
                    :status => (feature['status']) ? h_statuses[feature['status']] : 0
                  }
                  
                  #                 feature = TmpFeature.find(:first, :conditions => h_feature)
                  #                if !feature
                  feature = TmpFeature.new(h_feature)
                  feature.save
                  #                end                
                  #                if feature and h_feature_types[feature['type']].name == 'sequence conflict'
                  #                  h_variant={
                  #                    :feature_id => feature.id,
                  #                    :original => (ori = feature.at("original")) ? ori.innerHTML : nil,
                  #                    :variation => (variation = feature.at("variation")) ? variation.innerHTML : nil
                  #                  }
                  #                  #   variant = Variant.find(:first, :conditions => h_variant)
                  #                  #   if !variant
                  #                  variant = Variant.new(h_variant)
                  #                  variant.save
                  #                  #   end
                  #                end
                  
                  #                res[protein.id].push(h_feature)
                end    
              end
            end
            
          end
        end
        
      end
 #     return res
    end
    

    `psql -c 'drop table tmp_features' swisspalm`
    `psql -c 'create table tmp_features(id serial, feature_type_id int references feature_types, protein_id int references proteins, start int, stop int, description text, status smallint, original text, variation text, primary key (id))' swisspalm`
   # `psql -c 'create index tmp_features_value_idx on tmp_features (value)' swisspalm`
    `psql -c 'create index tmp_features_protein_id_feature_type_id_start_idx on tmp_features(protein_id, feature_type_id, start);`

    
    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    
    h_feature_types = {}
    FeatureType.all.map{|e| h_feature_types[e.name]=e}
    
    Organism.all.select{|o| true}.each do |organism|
      
      puts "Get #{organism.name} proteins..."
      h_proteins = {}
      h_existing_features = {}
      organism.proteins.map{|e| h_proteins[e.id]=e; h_existing_features[e.id]=[]}
      
      puts "Loading #{organism.name} data..."
      
      ##read features from xml      
      
      load_protein_features(organism, h_feature_types)      
    end
    
    ### switch
    `psql -c 'drop table old_features' swisspalm`
    `psql -c 'alter table features rename to old_features' swisspalm`
    `psql -c 'alter table tmp_features rename to features' swisspalm`

    ### rename index
    `psql -c 'ALTER INDEX tmp_features_protein_id_feature_type_id_start_idx RENAME TO features_protein_id_feature_type_id_start_idx' swisspalm`


  end  
end


