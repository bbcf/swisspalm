namespace :swisspalm do

  desc "Find pat groups"
  task :find_pat_groups, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include LoadData

    blast_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues' + 'blast_results'

    proteins = Protein.find(:all, :conditions => {:is_a_pat => true})    
    isoforms = Isoform.find(:all, :conditions => {:protein_id => proteins.map{|p| p.id}})
    h_isoforms = {}
    isoforms.map{|i| h_isoforms[i.id]=i}
    homologues = Homologue.find(:all, :conditions => ["(isoform_id1 in (?) or isoform_id2 in (?)) and (evalue_power is null or evalue_power < -20)", h_isoforms.keys, h_isoforms.keys])
    puts homologues.size
    

    h_homologues={}
    homologues.each do |homologue|
      h_homologues[homologue.isoform_id1]||=[]
      h_homologues[homologue.isoform_id1].push(homologue.isoform_id2) if !h_homologues[homologue.isoform_id1].include?(homologue.isoform_id2)
      h_homologues[homologue.isoform_id2]||=[]
      h_homologues[homologue.isoform_id2].push(homologue.isoform_id1) if !h_homologues[homologue.isoform_id2].include?(homologue.isoform_id1)
    end
    
    sorted_list = h_homologues.keys.sort{|a, b| h_homologues[a].size <=> h_homologues[b].size}.reverse
    
    puts "number of isoforms: " + sorted_list.size.to_s
    
    groups = []

    tmp_list=[]

    sorted_list.each do |e|
      found=-1
      max_links_found=0
      groups.each_index do |g_index|
        g = groups[g_index]
        count_links_with_group = 0
        g.each do |isoform|          
          if h_homologues[e].include?(isoform) #or h_homologues[isoform].include?(e)
            count_links_with_group += 1
          end
        end
        if count_links_with_group > max_links_found
#	puts count_links_with_group
          found = g_index
          max_links_found = count_links_with_group
        end
      end
      if found == -1
        puts "#{e} -> #{h_homologues[e].size}"
        puts h_homologues[e].to_json if h_homologues[e].size ==1
        groups.push([e])
      else
        groups[found].push(e)
      end      
    end
    
    puts "# of groups: " + groups.size.to_s 
    
    h_groups_by_isoform={}
    groups.each_index do |gid|
      group = groups[gid]
      
      isoforms = Isoform.find(:all, :conditions => {:id => group})                                                                
      isoforms.each do |isoform|
        if pat_isoform = isoform.pat_isoform
          pat_isoform.update_attribute(:homology_group, gid+1) 
        else
          pat_isoform = PatIsoform.new({:isoform_id => isoform.id, :homology_group => gid+1})
          pat_isoform.save
        end
      end

    end
    
    ### if want to save links between groups

#      group.each do |i|
#        h_groups_by_isoform[i]||=[]
#        h_groups_by_isoform[i].push(gid)
#      end
#    end
#
#    groups.each_index do |gid|
#      group = groups[gid]
#      group.each do |i|
##        isoform.update_attribute(:homology_groups, gid+1)
#        h_homologues[i].each_key do |foreign_isoform|
#          h_groups_by_isoform[foreign_isoform].each do |foreign_isoform_group|
#            h_groups_by_isoform[i].push(foreign_isoform_group) if !h_groups_by_isoform[i].include(foreign_isoform_group)
#          end
#        end
#      end
#    end
#    
#    isoforms = Isoform.find(:all, :conditions => {:id =>  h_groups_by_isoform.keys})
#    h_isoforms={}                                                                                                                                 
#    isoforms.each do |i|                                                                                                                          
#      h_isoforms[i.id]=i                                                                                                                          
#    end                   
#    
#    h_groups_by_isoform.each_key do |isoform|      
#      isoform.update_attribute(:homology_groups, h_groups_by_isoform[isoform].join(","))
#    end

  end
end
