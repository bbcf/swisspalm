namespace :swisspalm do

  desc "Load diseases"
  task :load_diseases, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'nokogiri'
    include LoadData



    def load_diseases(organism)
      
      dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
      files = ["#{organism.taxid}.all.xml", "#{organism.taxid}_db_update_entries.xml"].reverse
      
	h_statuses = {
	'by similarity' => 0,
	'potential' => 1,
	'probable' => 2
	}

      h_nodes = {:name => 1, :description => 1, :acronym => 1}

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
          h={}
          
          reader.each do |node|
            
            if node.name == 'entry'
              up_ac = nil
              flag=0
              h = {}
            end
            
            if node.name == 'accession' and !up_ac            
              up_ac = node.inner_xml 
              protein = Protein.find_by_up_ac(up_ac)
              protein.diseases.delete_all
            end	

            if node.name == 'comment' and node.attribute('type')=='disease'
              flag=1
            end

            if node.name == 'disease' and up_ac and  h_proteins[up_ac] and node.inner_xml != ''
              h[:disease_id] = node.attribute('id')
              flag=2
            end
            
            if flag==2 and node.name == 'name' and node.inner_xml != ''
              h[:name] = node.inner_xml
            end
            if flag==2 and node.name == 'acronyme' and node.inner_xml != ''
              h[:acronyme] = node.inner_xml
            end
            if flag==2 and node.name == 'description' and node.inner_xml != ''
              h[:description] = node.inner_xml
                # puts h.to_json
                disease = Disease.find(:first, :conditions => h)
                if !disease
                  disease = Disease.new(h)
                  disease.save
                  #puts disease.to_json 
                end
              protein.diseases << disease
            end
            
          end
            
            
            #  nodes = node.children
            
            #              while node = node.next and h_nodes[node.name] do # do |node|
            #                h[node.name]=node.inner_xml if h_nodes[node.name]
            #              end
        #    disease = Disease.find(:first, :conditions => h)
        #    if !disease
        #      disease = Disease.new(h)
        #      # disease.save
        #      puts disease.to_json
        #    end
        #  end
          
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
      
      load_diseases(organism)
      
    end
    
  end  
end


