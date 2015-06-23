namespace :swisspalm do

  desc "Create hit lists (internal)"
  task :create_hit_lists, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    include LoadData

    hit_lists_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'uploads' + 'hit_lists'
    

    while(1)
   

      ### get hit lists to load
      hit_lists = HitList.find(:all, :conditions => {:status_id => 1})
      
      hit_lists.each do |hit_list|
        puts "Treating #{hit_list.id}..."

        hit_list.update_attribute(:status_id, 2)

#	begin
          
          study= hit_list.study
          organism_id = study.organism_id
          
        

          if hit_list.file_type_id == 1
            `dos2unix #{hit_lists_dir + (hit_list.id.to_s + ".txt")}`
            `mac2unix #{hit_lists_dir + (hit_list.id.to_s + ".txt")}`
            file = File.open(hit_lists_dir + (hit_list.id.to_s + ".txt"), 'r')
            file_content = file.readlines()
            #  create_hits(hit_list, )
            load_data_file(hit_list, file_content, organism_id, study.id)
          else
            #          `rake swisspalm:load_ms_data[#{hit_list.id}] --trace RAILS_ENV=development`
            `dos2unix #{hit_lists_dir + (hit_list.id.to_s + "_validated_proteins.txt")}`
            `mac2unix #{hit_lists_dir + (hit_list.id.to_s + "_validated_proteins.txt")}`
            file = File.open(hit_lists_dir + (hit_list.id.to_s + "_validated_proteins.txt"), 'r')
            file_content = file.readlines().split(/[\r\n]+/).flatten.reject{|e| e==''}
	    puts "Load data file..."
            load_data_file(hit_list, file_content, organism_id, study.id)
            
            ### load protein groups
            puts "Load protein groups..."
            `dos2unix #{hit_lists_dir + (hit_list.id.to_s + "_protein_groups.txt")}`
            `mac2unix #{hit_lists_dir + (hit_list.id.to_s + "_protein_groups.txt")}`
            file = File.open(hit_lists_dir + (hit_list.id.to_s + "_protein_groups.txt"), 'r')
            pg_file_content = file.readlines().split(/[\r\n]+/).flatten.reject{|e| e==''}
            load_protein_group_file(hit_list, pg_file_content, file_content)
          end
          
          hit_list.update_attribute(:status_id, 3)
       # expire_action(:controller => 'pages', :action => 'palmitome_comparison')
	puts "Finished working on " + hit_list.id.to_s
#        rescue Exception => e

#          hit_list.update_attribute(:status_id, 4)
#        end
      end
      
      sleep(10)
      
    end
    

  end
end
