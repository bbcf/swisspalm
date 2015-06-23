namespace :swisspalm do

  desc "Find pat and apt homologues"
  task :find_pat_apt_homologues, [:version] do |t, args|

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

    h_organisms={}
    Organism.all.map{|o| h_organisms[o.up_tag]=o}
    
    h_nr_species = {}
    h_species = {}
    unknown_prots = {}
    h_not_found={}

    
    #    Dir.new(blast_dir).entries.select{|e| !e.match(/^\./)}.each do |file|
    
    (Protein.find(:all, :conditions => {:is_a_pat => true}) | Protein.find(:all, :conditions => {:is_a_pat => false})).each do |protein|
      protein.isoforms.each do |isoform|
        
        file =blast_dir + (protein.up_ac + "-" + isoform.isoform.to_s + '.txt')
	
	if File.exists? file        

          puts "Reading blasting #{file}..."
          
          h_species[file]={}
          
          File.open(file, 'r') do |f|
            while(l = f.gets and tab = l.chomp.split(/\|/) ) do
              pre_id = tab[4].split(/\s+/)[0]
              id = pre_id.split(/\!/)[-1]
	      tab_params = tab[4].split("\t")
              id_percent = tab_params[1]
              ali_len = tab_params[2]
              
              evalue_power = (m = tab_params[9].match(/\d+e?(-\d+)/)) ?  m[1].to_i :  
                ((m = tab_params[9].match(/^(\d+)$/) and m[1]>0) ? m[1].size : nil )
              if !evalue_power or evalue_power < -10
                
                #	     puts tab_params.to_json
                #  if !l.match(/\-/) and m = l.match(/(tr|sp)\!([\w_]+)/)                    
                #      puts id              
                tab2 = id.split("_")
                if tab2.size == 2 
                  if  h_organisms[tab2[1]] 
                    species = tab2[1]
                    h_species[file][species]||=[]
                    h_species[file][species].push([id, id_percent, evalue_power]) #if !h_species[file][species]
                    h_nr_species[species]=1
                  end           
                else
                  ac = id
                  tab_ac = ac.split("-")
                  protein = Protein.find_by_up_ac(tab_ac[0])
                  isoform = nil
                  if !protein
                    puts "Don't know organism for " + id
                    unknown_prots[id.split("-")[0]]=1
                    h_species[file][nil]||=[]
                    h_species[file][nil].push([id.split("-")[0], id_percent, evalue_power])
                  else
                    h_species[file][species]||=[]
                    h_species[file][species].push([protein.up_id, id_percent, evalue_power]) #if !h_species[file][species]       
                    h_nr_species[species]=1
                  end
                end
              end
            end
          end
          
          puts file
          
          h_species[file].each_key do |k|
            puts h_species[file][k].join(", ")
            h_species[file][k].each do |e|
              tmp_protein = Protein.find_by_up_id(e.first) || Protein.find_by_up_ac(e.first)         
              flag_bad_ref_protein=0
              if tmp_protein
                tmp_protein.ref_proteins.select{|rp| rp.source_type_id == 1}.each do |rp|
                  if rp.value.match(/^---/)
#                    puts "bad!!"
                    flag_bad_ref_protein = 1
                  end
                end
              end
              if !tmp_protein or flag_bad_ref_protein == 1
               # puts "added"
                h_not_found[e.first]||=[]
                h_not_found[e.first].push(e[2])
              end
            end
          end
        end
      end
    end
    puts "#{h_not_found.keys.size} NOT FOUND: " + h_not_found.keys.map{|k| k + " : " + h_not_found[k].join(",")}.join("; ")

    if h_not_found.keys.size > 0
      filepath_xml=Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues' + "entries_to_add.xml"
      filepath_fasta =Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues' + "entries_to_add.fa"

      if !File.exists? filepath_xml or !File.exists? filepath_fasta
      
        outfile = Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues' + "entries_to_add.txt" 
        
        File.open(outfile, 'w') do |f|
          h_not_found.each_key do |k|
            f.write(k + "\n")
          end
        end
      
        job_key = retrieve_uniprot_entries(outfile)
        `wget -O #{filepath_fasta} http://www.uniprot.org/jobs/#{job_key}.fasta`
        `wget -O #{filepath_xml} http://www.uniprot.org/jobs/#{job_key}.xml`
        
      end

      list_proteins = load_uniprot_entries_from_xml(filepath_xml)
      puts "Added #{list_proteins.size}!"
      h_seq = read_fasta_file(filepath_fasta)
      create_isoforms(h_seq, nil)

    end

    puts "Second pass: finding isoform-specific homologies"
    h_homologues={}

    (Protein.find(:all, :conditions => {:is_a_pat => true}) | Protein.find(:all, :conditions => {:is_a_pat => false})).each do |protein|
      protein.isoforms.each do |isoform|

        file =blast_dir + (protein.up_ac + "-" + isoform.isoform.to_s + '.txt')

        if File.exists? file

          puts "Reading blasting #{file}..."

          h_species[file]={}

          File.open(file, 'r') do |f|
            while(l = f.gets and tab = l.chomp.split(/\|/) ) do
              pre_id = tab[4].split(/\s+/)[0]
              id = pre_id.split(/\!/)[-1]
              tab_params = tab[4].split("\t")
              id_percent = tab_params[1]
              ali_len = tab_params[2]

              evalue_power = (m = tab_params[9].match(/\d+e?(-\d+)/)) ?  m[1].to_i :
                ((m = tab_params[9].match(/^(\d+)$/) and m[1]>0) ? m[1].size : nil )
              if !evalue_power or evalue_power < -10
                target_protein=nil
                target_isoform=nil

                tab2 = id.split("_")
                if tab2.size == 2
                  if h_organisms[tab2[1]]
                    target_protein = Protein.find_by_up_id(id)
                    target_isoform = target_protein.isoforms.first if target_protein
                  end
                else
                  ac = id
                  tab_ac = ac.split("-")
                  target_protein = Protein.find_by_up_ac(tab_ac[0])
		  if target_protein
                    target_isoform = target_protein.isoforms.select{|e| e.isoform == tab_ac[1].to_i}.first 
                  else
                    puts "Not found #{ac}"
                  end
                end

                if isoform and target_isoform and isoform.id != target_isoform.id
                  ### add homologues
#                  l = [isoform.id, target_isoform.id].sort
                  h_homologue = {
                    :isoform_id1  => isoform.id,
                    :isoform_id2  => target_isoform.id,
                    :id_percent   => id_percent,
                    :ali_len      => ali_len,
                    :evalue_power => evalue_power 
                  }
                  homologue = Homologue.find(:first, :conditions => {:isoform_id1 => l[0], :isoform_id2 => l[1]})
                  if !homologue
                    homologue = Homologue.new(h_homologue)
                    homologue.save
                  elsif (evalue_power and homologue.evalue_power and evalue_power < homologue.evalue_power) or !evalue_power
                    homologue.update_attributes(h_homologue)
                  end                  
                end
              end
            end
          end
        end
      end
    end
  end
end
