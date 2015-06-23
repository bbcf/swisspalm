namespace :swisspalm do

  desc "Check isoforms"
  task :check_isoforms, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    ### check if there is a problem in isoforms
    
    Protein.all.each do |p|
      isoforms = p.isoforms
      h_new_isoforms = {}
	flag=0 
     isoforms.select{|i| i.latest_version == true}.map{|i| h_new_isoforms[i.isoform]=i; flag=1 if i.main == true}
     puts p.up_ac if flag==0
	 

     isoforms.select{|i| i.latest_version == false}.each do |old_isoform|
        puts p.up_ac + "-" + old_isoform.isoform.to_s if !h_new_isoforms[old_isoform.isoform]
#	puts  p.up_ac + "-" + old_isoform.isoform.to_s if old_isoform.main == true
      end
    end
  end
end
