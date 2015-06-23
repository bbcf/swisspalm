namespace :swisspalm do

  desc "Load palmpred"
  task :load_palmpred, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    
    ### open file
    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'predictions' + 'PalmPred'

    h_predictions = {}
    Prediction.all.map{|p| h_predictions[[p.isoform_id, p.pos]]=p}

    ### palmpred

    res = {}
    
    File.open(dir + 'all_prediction', 'r') do |f|
      while l = f.gets do
        l.chomp!
	#>102423:RSKRLCPTIAT:27:-1.0231613:0
        tab = l.split(":")
        isoform_id = tab[0].split(">").last.to_i
	pos = tab[2].to_i
        score = tab[3].to_f
#        prediction = Prediction.find(:first, :conditions => {:isoform_id => isoform_id, :pos => pos})
        if h_predictions[[isoform_id, pos]]
          h_predictions[[isoform_id, pos]].update_attribute(:pp_score, score)
        end
      end
    end
    

   
    
  end
end
