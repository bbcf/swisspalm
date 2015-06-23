namespace :swisspalm do

  desc "Compute site environment composition"
  task :compute_site_env_composition, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    include Basic
    
    Site.all.each do |site|
      puts site.cys_env.to_json
    end

  end
end
