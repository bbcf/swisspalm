namespace :swisspalm do

  desc "Check site list"
  task :check_site_list, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    nber_not_found=[]
    prot_not_found=[]

    cur_entry = ''
    cur_pos = ''
    f = File.open('list.txt', 'r')
    lines = f.readlines
  #  puts lines.to_json
    lines.each do |l|
      if m = l.match(/^>.{2}\|(\w+)/)
        cur_entry = m[1]        
      elsif m = l.match(/^(\d+)/)
        cur_pos = m[1].to_i
      	
        p = Protein.find(:first, :conditions => {:up_ac => cur_entry})
	if p
          main_iso =  p.isoforms.select{|i| i.main == true}.first
          puts p.up_ac + " -> " + ((main_iso) ? main_iso.isoform.to_s : 'NA')
	  if main_iso
            puts cur_pos.to_s + " => " + main_iso.seq[cur_pos-1]
	    hits = Hit.find(:all, :conditions => {:protein_id => p.id})
            sites = Site.find(:all, :conditions => {:hit_id => hits.map{|e| e.id}})
            puts sites.map{|e| e.pos}.join(",")
            if !(sites.map{|e| e.pos}).include?(cur_pos)
	      nber_not_found.push([cur_entry, cur_pos])
            end	
          end	
        else
          puts cur_entry + " is not found!!!!!!!!!"
          prot_not_found.push("#{cur_entry} => #{cur_pos}")
        end
      end
    end

    puts "PROT NOT FOUND: #{prot_not_found}"
    puts "NOT FOUND: #{nber_not_found.map{|e| e.join("\t")}.join("\n")}"
    
  end
end
