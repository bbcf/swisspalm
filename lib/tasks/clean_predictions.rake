namespace :swisspalm do
  
  desc "Clean predictions"
  task :clean_predictions, [:version] do |t, args|

    ### Use rails enviroment   

    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP      
    
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch

    
#    isoforms = Isoform.find(:all, :conditions => {:main => true, :latest_version => true})
#    h_isoforms = {}
#    isoforms.map{|i| h_isoforms[i.id]=i}
    predictions =Prediction.find(:all, :select => 'predictions.*, isoforms.seq', :joins => 'join isoforms on (isoforms.id = predictions.isoform_id)', 
                                 :conditions => {:isoforms =>{:main => true, :latest_version => true}})

    predictions.each do |pred|
     # isoform = h_isoforms[pred.isoform_id]
      if pred.seq[pred.pos-1]!= 'C'	
	puts pred.to_json
	puts pred.seq[pred.pos-1]
	pred.destroy
      end
      # puts pred.seq[pred.pos-1]
    end
    
  end
end
