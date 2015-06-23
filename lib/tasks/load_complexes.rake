namespace :swisspalm do

  desc "Load complexes"
  task :load_complexes, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'nokogiri'
    include LoadData



    def load_protein_complexes()
      
      dir = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads'

      File.open(dir + 'corum.csv', 'r') do |f|
        while (l = f.gets) do
          t = l.chomp.split(";")
          h = {
            :id => t[0],
            :name => t[1]
          }
          protein_complex = ProteinComplex.new(h)
          protein_complex.save
          list = t[4].split(",")
          proteins = Protein.find(:all, :conditions => {:up_ac => list})
          proteins.each do |p|
            p.protein_complexes << protein_complex
          end
        end
      end

    end
    

    `psql -c 'drop table protein_complexes' swisspalm`
    `psql -c 'create table protein_complexes(id int,name text,primary key (id))' swisspalm`
    #  `psql -c 'create index tmp_complexes_idx on tmp_interpro_matches(protein_id);`
    #  `psql -c 'create index tmp_interpro_matches_interpro_id_idx on tmp_interpro_matches(interpro_id);`
    
    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads'
    
    load_protein_complexes()
        
    ### switch
 #   `psql -c 'drop table old_complexes' swisspalm`
 #   `psql -c 'alter table complexes rename to old_complexes' swisspalm`
 #   `psql -c 'alter table tmp_interpro_matches rename to interpro_matches' swisspalm`

  #  ### rename index
  #  `psql -c 'ALTER INDEX tmp_interpro_matches_protein_id_idx RENAME TO interpro_matches_protein_id_idx' swisspalm`
  #  `psql -c 'ALTER INDEX tmp_interpro_matches_interpro_id_idx RENAME TO interpro_matches_interpro_id_idx' swisspalm`

  end  
end


