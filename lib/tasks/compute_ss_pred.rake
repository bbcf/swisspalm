
namespace :swisspalm do

  desc "Compute ss preditions"
  task :compute_ss_pred, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root}/config/environment"
    
    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include LoadData
    
    Isoform.all.select{|i| i.id == 47231}.each do |isoform|
      
      if File.exists?("/data/epfl/bbcf/swisspalm/predictions/PalmPred/checks/#{isoform.id}.chk") and !File.exists?("/data/epfl/bbcf/swisspalm/ss/psipred/ss/#{isoform.id}.ss")
        cmd = "cd /data/epfl/bbcf/swisspalm/ss/psipred/ && ./runpsipred_test #{isoform.id}"
        `#{cmd}`      
      end
    end

  end
end
