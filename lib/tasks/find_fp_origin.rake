namespace :swisspalm do

  desc "Find false positive origin"
  task :find_fp_origin, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

  h_studies = {}
    Study.all.map{|s| h_studies[s.id]=s}

h_articles = {}
Article.all.map{|a| h_articles[a.pmid]=a}

    proteins = Protein.find(:all, :conditions => {:has_hits_public => true,  :nber_cys_max => 0})
    h_proteins = {}
    proteins.map{|p| 
	hits = p.hits; 
	hits.map{|h| h_proteins[h.study_id]||=[]; h_proteins[h.study_id].push(p)}
    }	
    
    puts h_proteins.keys.map{|sid| article = h_articles[h_studies[sid].pmid];  "#{sid} #{article.authors} (#{article.year}) #{h_studies[sid].techniques.map{|t| t.name}.join(',')}=> #{h_proteins[sid].map{|p| p.up_id}.join(', ')}"}.to_yaml
	
  end
end
