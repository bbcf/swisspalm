namespace :swisspalm do

  desc "Cluster cystein environment"
  task :cluster_cys_env, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'

    human_isoforms = Isoform.find(:all, :joins => 'join proteins on (proteins.id = isoforms.protein_id)',  :conditions => {:proteins => {:organism_id => 1}} ) 
    human_cysteines = Prediction.find(:all, :conditions => {:isoform_id => human_isoforms.map{|e| e.id}})
    human_cys_envs = CysEnv.find(human_cysteines.map{|e| e.cys_env_id}.compact)

    puts human_cys_envs.size

  end
end
