namespace :swisspalm do

  desc "Load MA mask..."
  task :load_ma_mask, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'isoform_ma'
    
    #P00387          ---------------------------------MGAQLSTLGHMVLFPVWFLYSLLMKLF

	    
    Protein.all.each do |protein|

      isoforms = protein.isoforms
      if isoforms.size > 1
        puts protein.up_ac
        main_iso = isoforms.select{|e| e.main == true}.first.isoform
        h_isoforms = {}
        isoforms.map{|e| h_isoforms[e.isoform] = e}
        
        file = dir + "#{protein.up_ac}.clw"
        File.open(file, 'r') do |f|
          
          h_seq = {}
          isoforms.each do |isoform| ## initialization
            h_seq[isoform.isoform]=''
          end
          i = 0
          while (!f.eof? and l = f.readline)
            
            if m = l.match(/^([\w\-]+)\s+([\w\-]+)/) and i > 2
              t = m[1].split('-')
              iso = (t.size == 2) ? t[1] : main_iso
              h_seq[iso.to_i] += m[2]
            end
            i+=1
          end
          
          ### parse each sequence
          h_seq.each_key do |iso|
#	puts h_seq[iso]
            t_mask = []
            current_count=0
            prev_state=''
            current_state=''
            (0 .. h_seq[iso].size-1).to_a.each do |pos|
              current_state = (h_seq[iso][pos] == '-') ? '-' : ':'
              if current_state != prev_state 
                t_mask.push("#{prev_state}#{current_count}") if prev_state != ''
                current_count = 1 
              else
                current_count+=1
              end
              prev_state = current_state
            end
            t_mask.push("#{current_state}#{current_count}")
            mask = t_mask.join(",")
            #            puts iso.to_s + ": " + mask
            isoforms = Isoform.find(:all, :conditions => {:protein_id => protein.id, :isoform => iso})
            if isoforms.size == 1
              isoforms.first.update_attributes({:ma_mask => mask})
            else
              puts "Duplicate error for " + protein.up_ac
            end
          end
        end
      end
    end

  end	
end
