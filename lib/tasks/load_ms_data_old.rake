namespace :swisspalm do

  desc "Load MS data (internal)"
  task :load_ms_data_old, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    include Fetch
    
    data_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'ms_data'
    filename = 't001_S02'
    file = data_dir + (filename + ".txt")
    tax_id= '9606'

    output = data_dir + (filename + "_modified.txt")

    headers=[]
    
    hits=[]

    h_cases = [
               'Isoform-specific',
               #    'Several possible isoforms',
               'Unreviewed isoform',
               #  'Part of a group of several Swiss-Prot proteins; isoform-specific',
               #  'Part of a group of several Swiss-Prot proteins; several possible isoforms',
               #  'Unreviewed isoform',
               'Unreviewed protein'
    ]

    count =0
    File.open(file, 'r') do |f|
      while(l = f.gets)
	if count == 0
          headers = l.split(/\t/)
        elsif count > 0
          tab = l.split(/\t/)
          h_data={}
          (0 .. tab.size-1).each do |field_num|
            h_data[headers[field_num]]=tab[field_num]
          end
	#          puts h_data["Protein IDs"]
          list_isoform_acs = h_data["Protein IDs"].split(';')
          list_prot_acs = list_isoform_acs.map{|e| e.split("-")[0]}
          sp_entries = Protein.find(:all, :conditions => {:up_ac => list_prot_acs, :trembl => false})
          sp_isoform_entries=[]
          list_isoform_acs.each do |isoform_up_ac|
            tab = isoform_up_ac.split("-")
            isoform = nil
            if tab[1]
              isoform = Isoform.find(:first, 
                                     :joins => "join proteins on (proteins.id = protein_id)",
                                     :conditions => {
                                       :proteins => {:up_ac => tab[0]},
                                       :isoform => tab[1] 
                                     })
            else
              isoform = Isoform.find(:first,
                                     :joins => "join proteins on (proteins.id = protein_id)",
                                     :conditions => {
                                       :proteins => {:up_ac => tab[0]},
                                       :main => true
                                     })
            end
            sp_isoform_entries.push(isoform) if isoform
          end
          
          trembl_entries = list_prot_acs - sp_entries.map{|e| e.up_ac}
          puts "#{count} -> #{sp_entries.map{|e| e.up_ac}.join(',')}"
          
          flag_case={}
          #ms_result_entries={}

#          prot_group=0
          
          if sp_isoform_entries.size > 0
            sp_isoform_entries.each do |isoform_entry|
              up_ac = isoform_entry.protein.up_ac
              if isoform_entry.main == false
                up_ac += "-" + isoform_entry.isoform.to_s
              end
              flag_case[up_ac]=0
              #ms_result_entries[up_ac]=[up_ac]                                                      
            end
          end

	  if trembl_entries.size > 0 
	    puts "TrEMBL: " + list_prot_acs.join(',')
            gene_names={}
            h_trembl_entry_by_gene_name={}
            trembl_entries.each do |trembl_entry|
              # flag_case[tab[0]]=2
              e = Fetch.fetch_uniprot_entry(trembl_entry)
              e[:list_gene_names].each do |gn|
                gene_names[gn]=1
                h_trembl_entry_by_gene_name[gn]||={}
                h_trembl_entry_by_gene_name[gn][trembl_entry]=1
              end
            end
            #puts gene_names.keys.to_json
          

            url = "http://www.uniprot.org/uniprot/?query=(gene%3A#{gene_names.keys.join(" or ")})+AND+reviewed%3ayes+AND+taxonomy%3a%22#{tax_id}%22&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism,length"
            res = `wget -q -O - '#{url}'`.split("\n")
            sleep(1)
            puts "==========>Number of SP entries: " + (res.size-1).to_s            
            #     if res.size > 2
            #       prot_group=1
            #     end
            if res.size >1
              
              (1 .. res.size-1).each do |i|
                tab = res[i].split("\t")   
                sp_entries.push(tab[0])
                sp_prot = Protein.find_by_up_ac(tab[0])
                # sp_gene_names = sp_prot.ref_proteins.select{|pr| pr.source_type.name=='gene_name'}.map{|e| e.value}
                # sp_gene_names.each do |e|
                #   if h_trembl_entry_by_gene_name[e]
                #     h_trembl_entry_by_gene_name[e].each_key do |trembl_entry|
                #       flag_case.delete(trembl_entry) if flag_case[trembl_entry]
                #       #ms_result_entries[tab[0]]||=[]
                #       #ms_result_entries[tab[0]].push(trembl_entry)
                #     end
                #   end
                # end
                
                flag_case[tab[0]]=1 if !flag_case[tab[0]]
                # list_isoforms_acs.push(tab[0])
              end
            end
            # if res.size > 1
            #  tab = res[1].split("\t")
            #  h_res[:protein]={
            #   :up_ac => tab[0],
            #   :up_id => tab[1],
            #   :description => tab[4],
            #   :organism_id => organism.id,
            #   :has_hits => true,
            #   :trembl => (tab[3] == 'unreviewed') ? true : false
            #  }
            #  h_res[:list_gene_names] = tab[5].split(' ');
            # end
            #elsif sp_entries.size == 1
            
          end

          ### complete flag_cases and ms_result_entries with the sp_isoform_entries that have not been yet attributed
          
          ## get all attributed entries
          #h_entries={}
          #ms_result_entries.each_key do |up_ac|
          #  ms_result_entries[up_ac].each do |entry|
          #    h_entries[entry]=1
          #  end
          #end
          
          ### check each sp_isoform_entries
          # list_isoform_acs.each do |up_ac| #sp_isoform_entries.each do |isoform_entry|
          #  # up_ac = isoform_entry.protein.up_ac
          #  # if isoform_entry.main == false
          #  #   up_ac += "-" + isoform_entry.isoform
          #  # end
          #  if !h_entries[up_ac]
          #    ms_result_entries[up_ac]=[up_ac]
          #    flag_case[up_ac]=2
          #  end
          #end
          
          #          ### add hits for each flag_case
          #
          #          h_isoforms={}
          #          list_isoform_acs.map{|e|
          #            tab = e.split("-")
          #            if tab[1]
          #              h_isoforms[tab[0]]||={}
          #              h_isoforms[tab[0]][tab[1]]=1
          #            end
          #          }
          
          flag_case.each_key do |up_ac|
            puts [up_ac, flag_case[up_ac], list_isoform_acs.join(',')].join("\t")
          end
                    
        end
        count+=1
      end
    end

  end
end
