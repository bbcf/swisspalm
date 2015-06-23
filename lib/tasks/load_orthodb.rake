namespace :swisspalm do

  desc "Load OrthoDB (internal)"
  task :load_orthodb, [:version] do |t, args|

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

  download_dir = Pathname.new(APP_CONFIG[:data_dir]) + "downloads"
    

    #    puts "Load new proteins..."
    #
    #    filepath_xml=Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_entries.xml"
    #    filepath_fasta =Pathname.new(APP_CONFIG[:data_dir]) + 'downloads' +  "oma_uniprot_sequences.fa"
    
    #    if File.exists?(filepath_xml)
    #      load_uniprot_entries_from_xml(filepath_xml)
    #    end
    #    if File.exists?(filepath_fasta)
    #      h_seq = read_fasta_file(filepath_fasta)
    #      create_isoforms(h_seq, nil)
    #    end
    
    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
    
    
    puts "Get proteins..."
    h_proteins = {}
    h_all_proteins={}
    Protein.all.map{|p| h_all_proteins[p.up_ac]=p.id; p}.select{|e| e.has_hits == true}.map{|e| h_proteins[e.up_ac] = e.id}
    
#    puts "Load OMA relation types"
#    h_oma_relation_types = {}
#    OmaRelationType.all.map{|ort| h_oma_relation_types[ort.name]=ort.id}
    
    puts "Second pass: loading mappings..."

    orthodb_metazoan_file = "#{download_dir}/orthodb_metazoa.txt.gz"
    orthodb_levels_file = "#{download_dir}/orthodb_levels.txt"
    orthodb_species_file = "#{download_dir}/orthodb_species.txt"
    
    h_levels = {}
    infile = open(orthodb_metazoan_file)
    gz = Zlib::GzipReader.new(infile)

    #ODB7_Level      ODB7_OG_ID      Protein_ID      Gene_ID Organism        UniProt_Species UniProt_ACC     UniProt_Description     InterPro_domains
    #45      EOG7002XC       ENSDARP00000102140      ENSDARG00000074465      Danio rerio     DANRE   E7F1S0  Uncharacterized protein IPR009543
    #45      EOG7002XC       ENSGMOP00000020997      ENSGMOG00000019508      Gadus morhua    GADMO   NULL    NULL    IPR009543

    puts "First pass: adding Uniprot entries..."

    i =0
    gz.each_line do |line|
      if i > 0
        line.chomp!
        tab = line.split("\t")
        if h_all_organisms[tab[5]] and h_all_proteins[tab[6]]

          h_orthodb_attr = {
            :protein_id => h_all_proteins[tab[6]],
            :orthodb_group_id => tab[1],
            :level => tab[0]
          }
          h_levels[tab[0]]=1 
          orthodb_attr = OrthodbAttr.find(:first, :conditions => h_orthodb_attr)
          if !orthodb_attr
            orthodb_attr = OrthodbAttr.new(h_orthodb_attr)
            orthodb_attr.save            
          end
        end
      end
      i+=1
    end
    gz.close

    ### load orthodb species
    h_species = {}
    File.open(orthodb_species_file, 'r') do |f|
      while (l = f.gets) do
        tab = l.chomp.split("\t")
        if tab.size > 2
          h_species[tab[0]]=tab[1]
        end
      end
    end

    ### load orthodb levels

    File.open(orthodb_levels_file, 'r') do |f|
      while (l = f.gets) do
        #ODB7_Level      Species
        #45      ACARO_AMELA_BTAUR_CFAMI_CGRIS_CHOFF_CJACC_CPORC_DNOVE_DORDI_DRERI_ECABA_EEURO_ETELF_FCATU_FHETE_GACUL_GGALL_GGORI_GMORH_HSAPI_ITRID_LAFRI_LCHAL_MDOME_MEUGE_MGALL_MLUCI_MMULA_MMURI_MMUSC_MPUTO_NLEUC_OANAT_OARIE_OCUNI_OGARN_OLATI_ONILO_OORCA_OPRIN_OROSM_PABEL_PANUB_PCAPE_PMARI_PSINE_PTROG_PVAMP_RNORV_SARAN_SBOLI_SHARR_SSCRO_TBELA_TGUTT_TMANA_TNIGR_TRUBR_TSYRI_TTRUN_VPACO_XMACU_XTROP
        #46      CJACC_SBOLI
        
        tab = l.chomp.split("\t")
        if h_levels[tab[0]]
          list_up_tags =  tab[1].split("_").map{|e| h_species[e]}
          h_orthodb_level = {
            :level => tab[0],            
            :organism_up_tags => list_up_tags.join(","),
            :organism_ids => Organism.find(:all, :conditions => {:up_tag => list_up_tags}).map{|e| e.id}.join(",")
          }
          orthodb_level=OrthodbLevel.find(:first, :conditions => {:level => tab[0]})
          if !orthodb_level
            orthodb_level = OrthodbLevel.new(h_orthodb_level)
            orthodb_level.save
          else
            orthodb_level.update_attributes(h_orthodb_level)
          end
        end
      end
    end
    
  end
end
