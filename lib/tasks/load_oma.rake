namespace :swisspalm do

  desc "Load OMA data (internal)"
  task :load_oma, [:version] do |t, args|

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
    

    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
      
    oma_uniprot_mapping_file = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' + 'oma-uniprot.txt.gz'
    oma_pairs_file = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' + 'oma-pairs.txt.gz'

    
    puts "Load OMA-Uniprot mapping file..."
    infile = open(oma_uniprot_mapping_file)
    gz = Zlib::GzipReader.new(infile)

    h_oma_mapping = {}

    gz.each_line do |line|
      line.chomp!
      #BACSU00009      IMDH_BACSU
      #BACSU00009      P21879

      tab = line.split("\t")
      h_oma_mapping[tab[0]]=tab[1] if tab[1] and tab[1].size == 6
#      if line.match(/P27824/)
#	puts line
#        puts "Found OMA mapping for #{h_oma_mapping[tab[0]]} -> #{tab1}"
#      end
 
    end
    
    puts "==> " + h_oma_mapping.keys.size.to_s + " mappings found."

    outfile = "#{APP_CONFIG[:data_dir]}/downloads/ac_to_load.txt"   

    filepath_xml=Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_entries.xml"
    filepath_fasta =Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_sequences.fa"

    if File.exists?(filepath_xml)
      
      ### load UniProt entries
      
      doc = open(filepath_xml) { |f| Hpricot(f) }    
      doc.search("entry").each do |entry|
        reviewed = (entry['dataset'] == 'Swiss-Prot') ? true : false
        accessions = entry.search("accession")
        up_ac = accessions.first.innerHTML
        up_id = entry.at("name").innerHTML
        
        submitted_names = entry.at("protein").search("submittedname")
        recommended_name = entry.at("protein").at("recommendedname")
        main_name = (recommended_name) ? recommended_name.at("fullname").innerHTML : submitted_names.shift.at("fullname").innerHTML
        description = main_name
        description += " " + submitted_names.map{|e| "(#{e.at("fullname").innerHTML})"}.join(' ') if submitted_names
        taxid = entry.at("organism").at("dbreference")['id']
        organism = Organism.find_by_taxid(taxid)
        gene = entry.at("gene")
        gene_names = (gene) ? gene.search("name").map{|e| e.innerHTML} : []
        
        h_res={}
        
        h_res[:protein]={
          :up_ac => up_ac,
          :up_id => up_id,
          :description => description,
          :organism_id => (organism) ? organism.id : nil,
          :has_hits => false,
          :trembl => reviewed
        }
        h_res[:list_gene_names] = gene_names#.split(' ');
        
        create_protein(h_res, 'up_ac', up_ac)
        
      end
    end
    if File.exists?(filepath_fasta)
      h_seq = read_fasta_file(filepath_fasta)
      create_isoforms(h_seq, nil)
    end
    
    puts "Get proteins..."
    h_proteins = {}
    h_all_proteins={}
    Protein.all.map{|p| h_all_proteins[p.up_ac]=p.id; p}.select{|e| e.has_hits == true}.map{|e| h_proteins[e.up_ac] = e.id}
    
    puts "Load OMA relation types"
    h_oma_relation_types = {}
    OmaRelationType.all.map{|ort| h_oma_relation_types[ort.name]=ort.id}
    
    puts "Second pass: loading mappings..."
    
    puts "Found CANX: #{h_proteins['P27824']}" if h_proteins['P27824']
    
    infile = open(oma_pairs_file)
    gz = Zlib::GzipReader.new(infile)
    gz.each_line do |line|
      line.chomp!
      tab = line.split("\t")

      ### find oma_relation_type                                                                                                                                                                                    
      ort = nil
      if !h_oma_relation_types[tab[2]]
        ort = OmaRelationType.new({:name => tab[2]})
        ort.save
        h_oma_relation_types[ort.name]=ort.id
      end

      ac1 = h_oma_mapping[tab[0]]
      ac2 = h_oma_mapping[tab[1]]

#      if ac1 == 'P27824' or ac2 == 'P27824'
#        puts "Should maybe add mapping #{ac1} - #{ac2} => #{h_proteins[ac1]}, #{h_proteins[ac2]}, #{h_all_proteins[ac1]}, #{h_all_proteins[ac2]}" 
#      end

      if (h_all_proteins[ac1] and h_proteins[ac2]) or (h_proteins[ac1] and h_all_proteins[ac2])
        
        h_oma_pair = {
          :protein_id1 => h_all_proteins[ac1],
          :protein_id2 => h_all_proteins[ac2],
          :oma_relation_type_id => h_oma_relation_types[tab[2]],
          :oma_group_id => tab[3]
        }
        oma_pair = OmaPair.find(:first, :conditions => {
                                  :protein_id1 => h_all_proteins[ac1],
                                  :protein_id2 => h_all_proteins[ac2]})
        if !oma_pair
          oma_pair = OmaPair.find(:first, :conditions => {
                                  :protein_id1 => h_all_proteins[ac2],
                                    :protein_id2 => h_all_proteins[ac1]})
        end
        if !oma_pair
          oma_pair= OmaPair.new(h_oma_pair)
          oma_pair.save
        else
          oma_pair.update_attributes(h_oma_pair)
        end
      end
    end
    gz.close
    
  end
end
