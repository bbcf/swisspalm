namespace :swisspalm do

  desc "Create cystein environment"
  task :create_cys_envs, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

#    h_cys_env = {}
    window = 5

#    h_sites = {}

    list_cys = []

    puts "Loading data..."

    
    def add_cys_env(isoform, pos, obj, window)
      
      #      list_cys.uniq.each do |isoform, pos|
      start_pos = pos - window   
      start_seq = ( start_pos < 1) ? "*" * -(start_pos-1) : ''
      end_pos = pos + window             
      end_seq = (end_pos > isoform.seq.size) ? "*" * (end_pos-isoform.seq.size) : ''
      start_pos = 1 if start_pos < 1                                                                                                                                          
      end_pos = isoform.seq.size if end_pos > isoform.seq.size
      seq = start_seq + isoform.seq[start_pos-1 .. end_pos-1] + end_seq                                                                                                                       
  #  puts "#{start_pos} -> #{end_pos} : #{cys_env}"
      
    #  h_cys_env[cys_env]||=[]                                                                                                                                                  
    #  h_cys_env[cys_env].push([isoform, pos])     
      
      h_cys_env = {:seq => seq}
#      puts h_cys_env.to_json
      cys_env = CysEnv.find(:first, :conditions => h_cys_env)
      if !cys_env
        cys_env = CysEnv.new(h_cys_env)
#	puts cys_env.to_json
        cys_env.save
      end
      obj.update_attribute(:cys_env_id, cys_env.id)
    end
    
    Site.all.each do |site|
      #  h_sites[site.isoform.id][site.pos]=1
      isoform = site.hit.isoform || site.hit.protein.isoforms.select{|i| i.main == true}.first
      #      list_cys.push([isoform, site.pos])
      add_cys_env(isoform, site.pos, site, window)
    end
    
    h_prediction={}
    Prediction.find(:all, :conditions => ['cp_high_cutoff > 0']).each do |cys|
      add_cys_env(cys.isoform, cys.pos, cys, window)
      #      list_cys.push([cys.isoform, cys.pos])
      #      h_prediction[[cys.isoform.id, cys.pos].join(',')]=cys
    end



  end
end
