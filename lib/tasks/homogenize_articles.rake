namespace :swisspalm do

  desc "Homogenize articles"
  task :homogenize_articles, [:version] do |t, args|
    
    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"
    
    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'
    require 'hpricot'
    include Fetch
    
    Study.all.each do |study|
      puts study.pmid
      if study.pmid
        
        res = fetch_pubmed(study.pmid)
	
        article.update_attributes(res)
    end
end	

  end	
end
