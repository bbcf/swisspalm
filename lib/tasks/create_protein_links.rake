namespace :swisspalm do

  desc "Create protein links"
  task :create_protein_links, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    
    h_source_types = {}
    SourceType.all.map{|e| h_source_types[e.name] = e.id}


    Protein.all.select{|e| e.has_hits }.each do |prot|

      h_refs = {
        :up_ac => [prot.up_ac],
        :up_id => [prot.up_id],
        :up_desc => [prot.description.split(/[^\w\d]+/).map{|e| e.downcase}.join(' ')],            
        :refseq => RefProtein.find(:all, :conditions => {:protein_id => prot.id, :source_type_id => h_source_types['refseq']}).map{|e| e.value},
        :ipi => RefProtein.find(:all, :conditions => {:protein_id => prot.id, :source_type_id => h_source_types['refseq']}).map{|e| e.value}
      }
      
      h_refs.each_key do |key|
        h_refs[key].each do |e|
          h= {
            :value => e,
            :source_type_id => h_source_types[key.to_s],
            :protein_id => prot.id
          }
          source_protein = ProteinLink.find(:first, :conditions => h)
          if !source_protein
            source_protein = ProteinLink.new(h)
            source_protein.save
          end
        end
      end
    end

  end
end
