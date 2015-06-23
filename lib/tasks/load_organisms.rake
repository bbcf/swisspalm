namespace :swisspalm do

  desc "Load organisms"
  task :load_organisms, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    
    puts "Get organisms..."
    h_organisms = {}
    Organism.all.map{|o| h_organisms[o.up_tag]=1}

    speclist_url = "http://www.uniprot.org/docs/speclist.txt"
    speclist_file = "#{APP_CONFIG[:data_dir]}/downloads/speclist.txt"

    `wget -O #{speclist_file} #{speclist_url}`

    start_flag = 0

    inclusion_list = ['DROME', 'DANRE', 'HV1H2', 'SPOFR', 'CHICK', 'HHV1', 'SFV', 'SINDV', 'RABIT', 'PIG', 'TOXGO']

    #_____ _ _______ _____________________________________________________________
    #AADNV V  648330: N=Aedes albopictus densovirus (isolate Boublik/1994)
    
    File.open(speclist_file, 'r') do |f|
      while(l = f.gets)
        #        puts l
        l.chomp!
        if m = l.match(/^(\w+)\s+([ABEV])\s+(\d+)\:\s+N=(.+)/) and inclusion_list.include?(m[1])
          h_organism = {
            :name => m[4],
            :up_tag => m[1],
            :kingdom => m[2],
            :taxid => m[3]
          }
        #  puts h_organism.to_json
          organism = Organism.find_by_taxid(m[3].to_i)
          if !organism
            organism = Organism.new(h_organism)
            organism.save
          else
            organism.update_attributes(h_organism)
          end
        end        
      end
    end
    
  end
end
