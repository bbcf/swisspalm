namespace :swisspalm do

  desc "Download data"
  task :download, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    include LoadData

    latest_refseq_version=59
    refseq_catalog = 'ftp://ftp.ncbi.nlm.nih.gov/refseq/release/release-catalog/RefSeq-release' + latest_refseq_version.to_s + '.catalog.gz'
    latest_ensemblgenomes_release=21
    ensemblgenomes_base_url = "ftp://ftp.ensemblgenomes.org/pub/release-" + latest_ensemblgenomes_release.to_s
    latest_ensembl_release=75
    ensembl_base_url = "ftp://ftp.ensembl.org/pub/release-" + latest_ensembl_release.to_s
    ipi_base_url = "ftp://ftp.ebi.ac.uk/pub/databases/IPI/last_release/current/"


    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    download_dir =  Pathname.new(APP_CONFIG[:data_dir]) + 'downloads'

    ### get phosphosite data
    phosphosite_files = [
                         'Acetylation_site_dataset.gz', 
                         'Ubiquitination_site_dataset.gz',
                         'Methylation_site_dataset.gz',
                         'Sumoylation_site_dataset.gz',
                         'Phosphorylation_site_dataset.gz',
                         'Disease-associated_sites.gz'
                        ]
    phosphosite_base_url = 'www.phosphosite.org/downloads/'
    Dir.mkdir(download_dir + 'phosphosite') if !File.exists?(download_dir + 'phosphosite')
    phosphosite_files.each do |f|
      local_file = download_dir + 'phosphosite' + f
      if !File.exists?(local_file)
        `wget -O #{local_file} #{phosphosite_base_url}#{f}`
        `gunzip #{local_file}`
      end
    end
    
    ### get phyloXML files from compara
    
    if !File.exists?(download_dir + "compara")
      Dir.mkdir(download_dir + "compara")
      url = "ftp://ftp.ensembl.org/pub/release-75/xml/ensembl-compara/homologies/Compara.75.protein.tree.phyloxml.xml.tar.gz"
      phyloxml_file = download_dir + "compara" + "phyloxml.tar.gz"
      if !File.exists?(phyloxml_file)
        `wget -O #{phyloxml_file} #{url}`
       	Dir.chdir(download_dir + "compara") do	 
          `tar -zxvf #{phyloxml_file}` 	
        end
      end
    end

    ### get CORUM database

    `wget -O #{download_dir + 'corum.csv'} http://mips.helmholtz-muenchen.de/genre/proj/corum/allComplexes.csv`

    ### for each organism, download the fasta file from ensembl
    Organism.all.select{|e| e.ensembl_assembly}.each do |o|
      organism_name = o.name.split(" ").join("_").downcase
      url = ensembl_base_url
      release = latest_ensembl_release
      if o.ensemblgenomes_section
        url = ensemblgenomes_base_url + o.ensemblgenomes_section 
        release = latest_ensemblgenomes_release
      end
      
      url += "/fasta/" + organism_name + "/pep/" + organism_name.capitalize + "." + o.ensembl_assembly + ".#{release}.pep.all.fa.gz"
      puts url
      filepath = dir + "#{o.taxid}.ensembl.fa.gz"
      `wget -O #{filepath} #{url}` if !File.exists?(filepath)
    end

    
    ### TAIR isoforms
    puts "Download TAIR sequences"
    url = "ftp://ftp.arabidopsis.org/home/tair/Proteins/TAIR10_protein_lists/TAIR10_pep_20101214"
    name = Organism.find_by_name("Arabidopsis thaliana").taxid #"arabidopsis_thaliana_isoform_sequences"
    if !File.exists?("#{dir}/#{name}.tair.fa")
      cmd = "wget -O #{dir}/#{name}.tair.fa '#{url}'"
      `#{cmd}`
    end
    
    ### go terms                  
    puts "Download go terms..."
    Organism.all.each do |o|
      if  o.go_url_part and  o.go_url_part!=''
        url = "http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association." + o.go_url_part + ".gz?rev=HEAD"
        name = o.taxid.to_s  
        if !File.exists?("#{dir}/#{name}.go")
          cmd = "wget -O #{dir}/#{name}.go.gz '#{url}'"
          `#{cmd}`
          `gunzip #{dir}/#{name}.go.gz`		
        end
      end
    end

    puts "Download refseq catalog..."
    `wget -O #{dir}/refseq_catalog.gz '#{refseq_catalog}'`
    h_text = "{" + 
    Organism.all.map{ |o|
      "#{o.taxid} => 1" 
    }.join(",") + "}"
    cmd ="less #{dir}/refseq_catalog.gz | perl -ne 'my $h=#{h_text}; if ((/NP_/) && /^(\\d+)/ && $h->{$1}) {print $_}' > #{dir}/refseq_catalog_proteins.txt"
    `#{cmd}`	     

    h_seq = {}
    puts "Read existing sequences..."
    if File.exists?(dir + "refseq_proteins.fa")
      lines =[]
      File.open(dir + "refseq_proteins.fa") do |f|
        lines = f.read.split(/\n/)
      end
      
      ac=''
      lines.each do |l|
        if m=l.match(/^>.+?\|ref\|(.+?)\|/)
          ac = m[1]	 
          if h_seq[ac]
            puts "error with #{ac}"
          else
            h_seq[ac]=''
          end
        else
          h_seq[ac]+=l
        end
      end
    end

    begin    
      File.open(dir + "refseq_catalog_proteins.txt") do |f|
        while (l = f.readline) do
          #        puts l
          tab = l.split(/\t/)
          if !h_seq[tab[2]]
            url = "http://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?tool=portal&db=protein&val=#{tab[2]}&page_size=5&fmt_mask=0&report=fasta&retmode=text&page=1&page_size=5\n"
            puts "Download #{url}\n"          
            download(dir + "refseq_proteins.fa", url)
          else
            #    puts "#{tab[2]} already there!"
          end
        end
      end
    rescue EOFError
      # Finished processing the file
    end
    
    
    Organism.all.each do |organism|
      puts "Retrieving files for #{organism.name}..." 	     
      name = organism.taxid.to_s
      #name = organism.name.downcase.split("[ \(\)]").join("_")
      #query_name = organism.name.downcase.split(" ").join("+")
      taxid = organism.taxid
      files = {
        name + ".tab" => "http://www.uniprot.org/uniprot/?query=(taxonomy%3a%22#{taxid}%22)+AND+reviewed%3ayes&force=yes&format=tab&columns=id,entry%20name,reviewed,protein%20names,genes,organism,length",
        name + ".fa" => "http://www.uniprot.org/uniprot/?query=(taxonomy%3a%22#{taxid}%22)+AND+reviewed%3ayes&force=yes&format=fasta&include=yes",
        name + ".gff" => "http://www.uniprot.org/uniprot/?query=(taxonomy%3a%22#{taxid}%22)+AND+reviewed%3ayes&force=yes&format=gff",
	name + ".list" => "http://www.uniprot.org/uniprot/?query=(taxonomy%3a%22#{taxid}%22)+AND+reviewed%3ayes&force=yes&format=list",
	name + ".xml" => "http://www.uniprot.org/uniprot/?query=taxonomy%3a%22#{taxid}%22+AND+annotation%3a(type%3alipid+palmitoyl+confidence%3aexperimental)&format=xml",
        name + ".all.xml" => "http://www.uniprot.org/uniprot/?query=taxonomy%3a%22#{taxid}%22+AND+reviewed%3Ayes&format=xml"
      }	

      files.each_key do |filename|
        filepath = dir + filename        
        `wget -O #{filepath} '#{files[filename]}'` if !File.exists?(filepath)       
      end

      #### complement .list files to get mapping on TrEMBL entries => OBSOLETE

      proteins = organism.proteins
      h_proteins = {}
      #      proteins.map{|p| h_proteins[p.up_ac]=1}
      file = File.open(dir + (name + '.list')) 
      file.readlines.each do |line|
        h_proteins[line.chomp]=1
      end
      #      File.open(dir + (name + '.list'), 'a') do |file|
      #        proteins.select{|p| !h_proteins[p.up_ac]}.each do |p|
      #          file.write(p.up_ac + "\n")
      #        end
      #      end
 
      #### complement .tab and .fa files with proteins already in the database
    
      outfile = dir + "#{name}_db_update.list"
      list_up_ac_to_add = proteins.select{|p| !h_proteins[p.up_ac]}.map{|p| p.up_ac}
      if list_up_ac_to_add.size > 0
        File.open(outfile, 'w') do |f_out|
          list_up_ac_to_add.each do |up_ac|
            f_out.write("#{up_ac}\n")
          end
        end
        
        filepath_xml = dir + "#{name}_db_update_entries.xml"
        filepath_fasta = dir + "#{name}_db_update_sequences.fa"

        if !File.exists?(filepath_xml) or !File.exists?(filepath_fasta) 
          job_key = retrieve_uniprot_entries(outfile)          
          `wget -O #{filepath_fasta} http://www.uniprot.org/jobs/#{job_key}.fasta`
          `wget -O #{filepath_xml} http://www.uniprot.org/jobs/#{job_key}.xml`
        end
      end
      
      #### get mappings in UniProt

      mappings=[ 
                ["P_IPI", "ipi"],
                ["P_REFSEQ_AC", "refseq"],
                ["MGI_ID", "mgi"],
                ["RGD_ID", "rgd"],
		["POMBASE_ID", "pombase"],#,
                ["EUPATHDB_ID", "eupathdb"],
                ["ENSEMBL_PRO_ID", "ensembl_prot"]
                #,
                #  ['TAIR_ID', "tair"]
               ]

      mappings.each do |mapping|
        
        filepath=dir + (name + "." + mapping[1] + ".txt")
        if !File.exists?(filepath)
          browser = Mechanize.new
          File.open(dir + (name + '.list')) do |message|	
            page = browser.post('http://www.uniprot.org/mapping/', {
                                  "file" => message,
                                  "from" => "ACC+ID",
                                  "to" => mapping[0],
                                  "query" => "",
                                  "url" => ""
                                }, {})
            browser.page().links().each do |link|
              if link.text() == 'mapping table'
                #puts link.href
                `wget -O #{filepath} http://www.uniprot.org/mapping/#{link.href}`
              end
            end
          end
        end
      end

      #### get annotation history in IPI

      filepath = dir + (name + ".ipi_history.txt")
      if !File.exists?(filepath)
        `wget -O #{filepath}.gz #{ipi_base_url}ipi.#{organism.up_tag}.history.gz`
        `gunzip #{filepath}.gz`
      end
	
    end

  end

  def download(file, url)
    
    uri = URI(url)
#    puts uri.to_s
    
    if uri.to_s.match(/^ftp/)
      ftp = Net::FTP.new(uri.host)
      ftp.login
      ftp.getbinaryfile(uri.path, file, 1024)
    else
      
      cmd = "wget -q -O - '#{uri}' | perl -ne 'if ($_ !~ /^\s*$/){ print $_}' >> #{file}"
 #      puts cmd
      `#{cmd}`
    end
  end
  

end


