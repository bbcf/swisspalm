namespace :swisspalm do
  
  desc "Count cys"
  task :count_cys, [:version] do |t, args|

    ### Use rails enviroment   

    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP      
    
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch

    counts=[]
    
    Protein.all.each do |p|
      
      list_nber_cys = []
      p.isoforms.each do |i|
        list_nber_cys.push(i.seq.count('C'))
      end

      p.update_attribute(:nber_cys_max, list_nber_cys.sort.last)
      
    end
    
  end	
end
