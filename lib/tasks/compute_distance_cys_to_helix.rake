namespace :swisspalm do

  desc "Compute distance from cysteines to helix"
  task :compute_distance_cys_to_helix, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    
    h_ss = {'H' => 1, 'E' => 2, 'C' => 3}
    
    Isoform.all.each do |isoform|
      
      ### get ss predictions
      
      filepath = Pathname.new(APP_CONFIG[:data_dir]) + 'ss' + 'psipred' + 'ss' + (isoform.id.to_s + ".ss")
      
      ss_list = []
      
      if File.exists?(filepath)
        File.open(filepath, 'r') do |f|
          while (l = f.gets) do
            tab = l.strip.split(/\s+/)
            # pos = tab[0].to_i
            ss_list.push(h_ss[tab[2]])
          end
        end
      end
      
      
    end
  end
end
