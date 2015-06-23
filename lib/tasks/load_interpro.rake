namespace :swisspalm do

  desc "Load InterPro"
  task :load_interpro, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'nokogiri'
    include LoadData



    def load_interpro_matches(organism)
      
      dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
      files = ["#{organism.taxid}.all.xml", "#{organism.taxid}_db_update_entries.xml"].reverse
      
      h_proteins={}
      Protein.find(:all, :conditions => {:organism_id => organism.id}).map{|p| h_proteins[p.up_ac]=p}

      res = {}
      
      files.each do |file|
        
        filepath_xml = dir + file
        if File.exists?(filepath_xml)
          puts "read #{filepath_xml}..."
          
#          doc = open(filepath_xml) { |f| Hpricot(f) }
#          doc.search("entry").each do |entry|
          reader = Nokogiri::XML::Reader(File.open(filepath_xml))
          up_ac = nil
          trembl = nil
          interpro_id = nil
          
          reader.each do |node|
            
            if node.name == 'entry'
              up_ac = nil
            end

            
            if node.name == 'accession' and !up_ac            
              up_ac = node.inner_xml 
            end	

            if node.name == 'dbReference' and node.attribute('type')=='InterPro'
              if m = node.attribute('id').match(/(\d+)/)
                interpro_id = m[1]
              end		
            end
            
            if up_ac and interpro_id and h_proteins[up_ac] and node.name == 'property' and node.attribute('type')=='entry name'
              puts "UP_AC:" + up_ac.to_json if ! h_proteins[up_ac]
              #	puts bla

              h_interpro = {
                :id => interpro_id,
                :description => node.attribute('value')
              }
              if !Interpro.find(:first, :conditions => h_interpro)
                interpro = Interpro.new(h_interpro)
                interpro.save 
              end

              h_interpro_match = {
                :protein_id => h_proteins[up_ac].id,
                :interpro_id => interpro_id,
                :description => node.attribute('value')
              }
              interpro_match = TmpInterproMatch.new(h_interpro_match)
              interpro_match.save
              interpro_id = nil
            end
            
          end
        end
      end
    end
    

    `psql -c 'drop table tmp_interpro_matches' swisspalm`
    `psql -c 'create table tmp_interpro_matches(id serial,protein_id int references proteins,interpro_id int,description text,primary key (id))' swisspalm`
    `psql -c 'create index tmp_interpro_matches_protein_id_idx on tmp_interpro_matches(protein_id);`
    `psql -c 'create index tmp_interpro_matches_interpro_id_idx on tmp_interpro_matches(interpro_id);`
    
    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    
    h_feature_types = {}
    FeatureType.all.map{|e| h_feature_types[e.name]=e}
    
    Organism.all.select{|o| true}.each do |organism|
      
      puts "Get #{organism.name} proteins..."
      h_proteins = {}
      organism.proteins.map{|e| h_proteins[e.id]=e;}
      
      puts "Loading #{organism.name} data..."
      
      ##read features from xml      
      
      load_interpro_matches(organism)
      
    end
    
    ### switch
    `psql -c 'drop table old_interpro_matches' swisspalm`
    `psql -c 'alter table interpro_matches rename to old_interpro_matches' swisspalm`
    `psql -c 'alter table tmp_interpro_matches rename to interpro_matches' swisspalm`

    ### rename index
    `psql -c 'ALTER INDEX tmp_interpro_matches_protein_id_idx RENAME TO interpro_matches_protein_id_idx' swisspalm`
    `psql -c 'ALTER INDEX tmp_interpro_matches_interpro_id_idx RENAME TO interpro_matches_interpro_id_idx' swisspalm`

  end  
end


