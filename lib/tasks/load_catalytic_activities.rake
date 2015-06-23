namespace :swisspalm do

  desc "Load catalytic activities"
  task :catalytic_activities, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'nokogiri'
    include LoadData



    def load_subcellular_locations(organism)
      
      dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
      files = ["#{organism.taxid}.all.xml", "#{organism.taxid}_db_update_entries.xml"].reverse
      
	h_statuses = {
	'by similarity' => 1,
	'potential' => 3,
	'probable' =>2
	}

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
          flag=0
          protein = nil
          reader.each do |node|
            
            if node.name == 'entry'
              up_ac = nil
              flag=0
            end
            
            if node.name == 'accession' and !up_ac            
              up_ac = node.inner_xml 
              protein = Protein.find_by_up_ac(up_ac)
              protein.subcellular_locations.delete_all
            end	

            if node.name == 'comment' and node.attribute('type')=='subcellular location'
              flag=1
            end
            
            if flag==1 and node.name == 'subcellularLocation'
              flag=2
            end

            if up_ac and flag==2 and h_proteins[up_ac] and node.name == 'location' 
       #       puts "UP_AC:" + up_ac.to_json #if ! h_proteins[up_ac]
              #	puts bla
#              puts node.inner_xml
              if status = node.attribute('status') and !h_statuses[status] and status!='http://uniprot.org/uniprot'
                puts "!!!!#{status}!!!!!"
              end
              h_location={:name => node.inner_xml}
              h_location[:status] = h_statuses[status] if  h_statuses[status] 
              location = SubcellularLocation.find(:first, :conditions => h_location)
              if !location
                location = SubcellularLocation.new(h_location)
                location.save
              end
#              puts location.to_json
              protein.subcellular_locations << location
              flag=1
            end
            
          end
        end
      end
    end
    

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    
    h_feature_types = {}
    FeatureType.all.map{|e| h_feature_types[e.name]=e}
    
    Organism.all.select{|o| true}.each do |organism|
      
      puts "Get #{organism.name} proteins..."
      h_proteins = {}
      organism.proteins.map{|e| h_proteins[e.id]=e;}
      
      puts "Loading #{organism.name} data..."
      
      ##read features from xml      
      
      load_subcellular_locations(organism)
      
    end
    
  end  
end


