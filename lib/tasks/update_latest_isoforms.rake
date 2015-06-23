namespace :swisspalm do

  desc "Update latest isoforms"
  task :update_latest_isoforms, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

	############### this script is obsolete!!!! The definition of the latest isoforms is now done in load_uniprot.rake

    `psql -c 'update isoforms set latest_version = true' swisspalm`

    h_isoforms = {}    
    h_latest_isoforms = {}
    isoforms = Isoform.find(:all, :order => "id desc")

    isoforms.each do |isoform|
      identifier = isoform.protein_id.to_s + "_" + isoform.isoform.to_s
      if !h_isoforms[identifier]
  	h_isoforms[identifier]=1
        h_latest_isoforms[isoform.id]=1
      end
    end
    
    isoforms.reject{|i| h_latest_isoforms[i.id]}.each do |isoform|
      isoform.update_attribute(:latest_version, false)
    end
    
  end
end
