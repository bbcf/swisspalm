namespace :swisspalm do

  desc "Download OrthoDB"
  task :download_orthodb, [:version] do |t, args|

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

    ### download OrthoDB files
    puts "Download OrthoDB files"
    h_urls = {
      "orthodb_metazoa.txt.gz" => "ftp://cegg.unige.ch/OrthoDB7/OrthoDB7_ALL_METAZOA_tabtext.gz",
      "orthodb_levels.txt" => "ftp://cegg.unige.ch/OrthoDB7/OrthoDB7_LEVELS_tabtext",
      "orthodb_species.txt" => "ftp://cegg.unige.ch/OrthoDB7/OrthoDB7_SPECIES_tabtext"
    }
    
    h_urls.each_key do |name| 
      if !File.exists?(download_dir + name)
        url = h_urls[name]
        cmd = "wget -O #{download_dir}/#{name} '#{url}'"
        `#{cmd}`
      end
    end
    
    ### Process OrthoDB files
    
    puts "Get proteins with hits..."
    h_proteins = {}
    h_all_proteins={}
    Protein.all.map{|p| h_all_proteins[p.up_ac]=p.id; p}.select{|e| e.has_hits == true}.map{|e| h_proteins[e.up_ac] = e.id}
 
    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
      
    #ODB7_Level      ODB7_OG_ID      Protein_ID      Gene_ID Organism        UniProt_Species UniProt_ACC     UniProt_Description     InterPro_domains
    #45      EOG7002XC       ENSDARP00000102140      ENSDARG00000074465      Danio rerio     DANRE   E7F1S0  Uncharacterized protein IPR009543
    #45      EOG7002XC       ENSGMOP00000020997      ENSGMOG00000019508      Gadus morhua    GADMO   NULL    NULL    IPR009543
    #  outfile = "#{APP_CONFIG[:data_dir]}/downloads/ac_to_load.txt"   

    h_groups = {}

    orthodb_metazoan_file = "#{download_dir}/orthodb_metazoa.txt.gz"

    infile = open(orthodb_metazoan_file)
    gz = Zlib::GzipReader.new(infile)
    
    puts "First pass: adding Uniprot entries..."
    

    i =0
    gz.each_line do |line|
      if i > 0
        line.chomp!
        tab = line.split("\t")      
        if h_all_organisms[tab[5]]
          h_groups[tab[1]]||=[]
          h_groups[tab[1]].push(tab[6]) if tab[6] != 'NULL' 
        end
      end
      i+=1
    end
    gz.close

    
    puts "Total groups = " + h_groups.keys.size.to_s

    outfile = "#{APP_CONFIG[:data_dir]}/downloads/ac_to_load.txt"

    h_to_add = {}
    groups=0
    ### filter groups without one palmitoylated protein
    h_groups.each_key do |group|
      keep=0;
      h_groups[group].each do |e|
        if h_proteins[e]
          keep=1
          break
        end
      end
      if keep==1
        h_groups[group].each do |e|
          if !h_all_proteins[e]
            h_to_add[e]=1
            #  f.write(e + "\n") 
          end
        end
        groups+=1
      end
    end
    
    File.open(outfile, 'w') do |f|
      h_to_add.each_key do |k|
        f.write(k + "\n")
      end
    end
    
    puts groups.to_s + " groups found with palmitoylated proteins";  
    
    f = File.new(outfile, 'r')
    nber_lines = f.readlines.size

    if nber_lines > 0
      ### submit retrieval of entries
      
      filepath_xml=Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "orthodb_uniprot_entries.xml"
      filepath_fasta =Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "orthodb_uniprot_sequences.fa"
      
#      job_key = retrieve_uniprot_entries(outfile)      
#      `wget -O #{filepath_fasta} http://www.uniprot.org/jobs/#{job_key}.fasta`
#      `wget -O #{filepath_xml} http://www.uniprot.org/jobs/#{job_key}.xml`
      
    end
  end
end
