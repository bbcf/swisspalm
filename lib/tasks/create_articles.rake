namespace :swisspalm do

  desc "Create articles"
  task :create_articles, [:version] do |t, args|
    
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

    pmids = Study.all.map{|s| s.pmid}.uniq
    
    pmids.each do |pmid|
      puts pmid
      if pmid
        res = Fetch.fetch_pubmed(pmid)
        article = Article.find_by_pmid(pmid)
        if !article
          puts res.to_json
	  res[:pmid]=pmid
          article = Article.new(res)
          article.save
	  puts article.errors.to_yaml
        else
          puts "update " + res.to_json
          article.update_attributes(res)
        end
      end
    end	
  end	
end
