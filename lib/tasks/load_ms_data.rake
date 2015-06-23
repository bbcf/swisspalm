namespace :swisspalm do

  desc "Load MS data (internal)"
  task :load_ms_data, [:hit_list_id] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'

    include Fetch
    
    puts "ID:"
    puts args.hit_list_id
    
    hit_lists_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'uploads' + 'hit_lists'
    filename = args.hit_list_id.to_s
    hit_list = HitList.find(args.hit_list_id)
    file = hit_lists_dir + (filename + ".txt")
    tax_id= hit_list.study.organism.taxid

    output = hit_lists_dir + (filename + "_validated_proteins.txt")
    
    out_headers = ['isoform_identifier', 'Protein group ID', 'Identification case']
    
    fw = File.open(output, 'w')
    fw.write(out_headers.join("\t") + "\n")    

    output2 = hit_lists_dir + (filename + "_protein_groups.txt")

    out_headers2= ['Protein group ID', 'Original protein list', 
	'Posterior error probability', 'Uncorrected t-test', 
	't-test difference', 'Number of peptides', #'t-test is significant?', 
	'One entry in protein group?']

    fw2 = File.open(output2, 'w')
    fw2.write(out_headers2.join("\t") + "\n")
    

    headers=[]
    
    hits=[]

    h_cases = [
               'Isoform-specific',
               'Unreviewed isoform',
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
          
          if hit_list.confidence_level_id == 3 and h_data['t-test Significant'] == '+' and h_data['t-test Difference'].to_f > 0.0
            
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
            
            if sp_isoform_entries.size > 0
              sp_isoform_entries.each do |isoform_entry|
                up_ac = isoform_entry.protein.up_ac
                if isoform_entry.main == false
                  up_ac += "-" + isoform_entry.isoform.to_s
                end
                flag_case[up_ac]=0
              end
            end
            
            if trembl_entries.size > 0
              
              gene_names={}
              h_trembl_entry_by_gene_name={}            
              
              list_accessions = trembl_entries.map{|e| "accession:#{e}"}
              
              url = "http://www.uniprot.org/uniprot/?query=(#{list_accessions.join(" or ")})+AND+reviewed%3ano+AND+taxonomy%3a%22#{tax_id}%22&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism,length"
              res = `wget -q -O - '#{url}'`.split("\n")
              sleep(1)
              puts "==========>Number of trEMBL entries: " + (res.size-1).to_s +  "(#{res.map{|e| e.split("\t")[0]}.join(',')})"
              if res.size >1
                
                (1 .. res.size-1).each do |i|
                  tab = res[i].split("\t")
                  flag_case[tab[0]]=2
                  if tab[4]!='Deleted.' and !tab[4].match(/^Merged into/)
                    tab[5].split(" ").each do |gn|
                      gene_names[gn]=1
                      h_trembl_entry_by_gene_name[gn]||={}                                                                                                  
                      h_trembl_entry_by_gene_name[gn][tab[0]]=1      
                    end
                  end
                end
              end
              
              #            puts gene_names.keys.join(" or ")
              list_gene_names = gene_names.keys.map{|e| "gene_exact%3A" + '"' + e + '"'}
              url = "http://www.uniprot.org/uniprot/?query=(#{list_gene_names.join(" or ")})+AND+reviewed%3ayes+AND+taxonomy%3a%22#{tax_id}%22&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism,length"
              res = `wget -q -O - '#{url}'`.split("\n")
              sleep(1)
              puts "==========>Number of SP entries: " + (res.size-1).to_s + "(#{res.map{|e| e.split("\t")[0]}.join(',')})"            
              
              if res.size >1 and res.size < 100
                
                (1 .. res.size-1).each do |i|
                  tab = res[i].split("\t")   
                  sp_entries.push(tab[0])
                  sp_gene_names = tab[5].split(' ')
                  sp_gene_names.each do |e|
                    if h_trembl_entry_by_gene_name[e]
                      h_trembl_entry_by_gene_name[e].each_key do |trembl_entry|
                        flag_case.delete(trembl_entry) if flag_case[trembl_entry]
                      end
                    end
                  end
                  flag_case[tab[0]]=1 if !flag_case[tab[0]] or flag_case[tab[0]]==2
                end
              elsif  res.size > 100
                puts "QUERY => #{url}"
              end
            end
            
            
            flag_case.each_key do |up_ac|
              hit=[up_ac, h_data["id"],  flag_case[up_ac]
                  ]
              hits.push(hit)
              puts hit.join("\t") + "\n"
              fw.write(hit.join("\t") + "\n")
            end
            protein_group_data=[h_data["id"], 
                                list_isoform_acs.join(','),
                                h_data["PEP"],
                                h_data["-Log t-test p value"],
                                h_data["t-test Difference"],
                                h_data["Peptide IDs"].split(";").size,
                           #     ((h_data["t-test Significant"] == '+') ? 'true' : 'false'),
                                ((flag_case.keys.size == 1) ? 'true' : 'false')	
                               ]
            fw2.write(protein_group_data.join("\t") + "\n")
            
          end
        end
        count+=1
     
      end
      
    end
    
  end
end
