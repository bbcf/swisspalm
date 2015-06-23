namespace :swisspalm do

  desc "Download OMA data (internal)"
  task :download_oma_groups, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    require 'mechanize'
    require 'hpricot'
    require 'bio'
    include LoadData
    include Fetch

    download_dir = Pathname.new(APP_CONFIG[:data_dir]) + "downloads"

    ### download OMA files
    puts "Download OMA files"
    h_urls = {
              "oma-groups.txt.gz" => "http://omabrowser.org/All/oma-groups.txt.gz",
              "oma-uniprot.txt.gz" => "http://omabrowser.org/All/oma-uniprot.txt.gz"
    }
    
    h_urls.each_key do |name| 
      if !File.exists?(download_dir + name)
        url = h_urls[name]
        cmd = "wget -O #{download_dir}/#{name} '#{url}'"
        `#{cmd}`
      end
    end
    
    ### Process OMA files
    
    puts "Get proteins with hits..."
    h_proteins = {}
    h_all_proteins={}
    Protein.all.map{|p| h_all_proteins[p.up_ac]=p.id; p}.select{|e| e.has_hits == true}.map{|e| h_proteins[e.up_ac] = e.id}
    puts "h_proteins: #{h_proteins.keys.size}."
    puts "h_all_proteins: #{h_all_proteins.keys.size}."

    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
      
    puts h_all_organisms.to_json

    oma_uniprot_mapping_file = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' + 'oma-uniprot.txt.gz'
    oma_groups_file = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' + 'oma-groups.txt.gz'

    
    puts "Load OMA-Uniprot mapping file..."
    infile = open(oma_uniprot_mapping_file)
    gz = Zlib::GzipReader.new(infile)

    h_oma_mapping = {}
    flag_organism_ok=0
    gz.each_line do |line|
      line.chomp!
      tab = line.split("\t")
      if tab[1] 
        if tab[1].size == 6 and flag_organism_ok == 1	
          h_oma_mapping[tab[0]]=tab[1]
           flag_organism_ok = 0
        elsif tab[1].size > 6
          if h_all_organisms[tab[1].split("_")[1]]
            flag_organism_ok = 1
          end
        end
      end
    end
    
    puts "==> " + h_oma_mapping.keys.size.to_s + " mappings found."

    outfile = "#{APP_CONFIG[:data_dir]}/downloads/ac_to_load.txt"   

    infile = open(oma_groups_file)
    gz = Zlib::GzipReader.new(infile)
    
    puts "First pass: adding Uniprot entries..."
    
    f_out = File.new(outfile, 'w')
    gz.each_line do |line|
      line.chomp!
      tab = line.split("\t")
      
      list_oma_ids = (2 .. tab.size-1).to_a.map{|i| tab[i]}
#      puts list_oma_ids.to_json

      (0 .. list_oma_ids.size-2).to_a.each do |i|
        
        ac1 = h_oma_mapping[list_oma_ids[i]]
        
        if ac1

         # puts ac1

          (i+1 .. list_oma_ids.size-1).to_a.each do |j|
            
            ac2 = h_oma_mapping[list_oma_ids[j]]
            
            if ac2 and ((h_proteins[ac1] and !h_all_proteins[ac2]) or (h_proteins[ac2] and !h_all_proteins[ac1])) 
              puts ac1 +" : " + ac2
              if !h_proteins[ac1]
                #          load_protein(ac1, nil, 'up_ac', false)
                f_out.write("#{ac1}\n")
                h_all_proteins[ac1]=1 #Protein.find_by_up_ac(ac1).id
              end
              if  !h_proteins[ac2]
                #          load_protein(ac2, nil, 'up_ac', false)
                f_out.write("#{ac2}\n")
                h_all_proteins[ac2]=1 #Protein.find_by_up_ac(ac2).id
              end
            end
          end
        end
      end
    end
    gz.close
    #   infile.close
    f_out.close
    
    # puts f_out.size 
    # exit

    f = File.new(outfile, 'r')
    nber_lines = f.readlines.size

    if nber_lines > 0
      ### submit retrieval of entries
      
      filepath_xml=Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_entries.xml"
      filepath_fasta =Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_sequences.fa"
      
      job_key = retrieve_uniprot_entries(outfile)
      
      `wget -O #{filepath_fasta} http://www.uniprot.org/jobs/#{job_key}.fasta`
      `wget -O #{filepath_xml} http://www.uniprot.org/jobs/#{job_key}.xml`
      
    end
  end
end
