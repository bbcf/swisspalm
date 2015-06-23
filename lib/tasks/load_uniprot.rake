namespace :swisspalm do

  desc "Load Uniprot"
  task :load_uniprot, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'

    include LoadData

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'
    

    def load_proteins(name, dir, organism, h_mappings, h_source_types)
      File.open(dir + (name + ".tab")) do |f|
        headers = f.readline.split(/\t/)
        
        while (l = f.gets) do
          tab = l.split(/\t/)
          h_tab = {}
          (0 .. tab.size-1).to_a.map{|i| h_tab[headers[i]]=tab[i]}
          h={
            :up_ac => tab[0],
            :up_id => tab[1],
            :description => tab[3],
            :organism_id => organism.id
          }

          prot = Protein.find(:first, :conditions => {:up_ac => tab[0]})
          if prot
            prot.update_attributes(h)
          else
            prot = Protein.new(h)
            prot.save
          end

          list_refs = [
                       {
                         :source_type => 'gene_name', 
                         :vals => tab[4].split(' '), 
                       },
                       {
                         :source_type => 'up_ac',
                         :vals => [tab[0]],
                       },
                       {
                         :source_type => 'up_id',
                         :vals => [tab[1]],
                       }
                      ]
          
          list_refs.each do |h_ref|
            h_ref[:vals].each do |val|
              # puts gn
              h = {
                :protein_id => prot.id,
                :value => val,
                :source_type_id => h_source_types[h_ref[:source_type]]
              }
              gene_name = RefProtein.find(:first, :conditions => h)
              if !gene_name
                gene_name = RefProtein.new(h)
                gene_name.save
              end
            end
          end

          ### add ref_proteins from basic info
          h_refs = {
            #            :up_ac => [prot.up_ac],
            #            :up_id => [prot.up_id],
            #            :up_desc => [prot.description.split(/[^\w\d]+/).map{|e| e.downcase}.join(' ')]            
          }	

          [:refseq, :ipi, :mgi, :rgd, :ensembl_prot].each do |source|
            if  h_mappings[source][prot.up_ac]
              h_refs[source] = h_mappings[source][prot.up_ac]
            end
          end

          h_refs.each_key do |key|
            h_refs[key].each do |e|
              h= {
                :value => e,
                :source_type_id => h_source_types[key.to_s],
                :protein_id => prot.id
              }
              source_protein = RefProtein.find(:first, :conditions => h)
              if !source_protein
                source_protein = RefProtein.new(h)
                source_protein.save
              end
            end
          end
       
        end
      end
      
      ### load complement
	
      filepath_xml = dir + "#{name}_db_update_entries.xml"
      filepath_fasta = dir + "#{name}_db_update_sequences.fa"
      if File.exists?(filepath_xml) and File.exists?(filepath_fasta)
        list_proteins = load_uniprot_entries_from_xml(filepath_xml)
        puts "Added #{list_proteins.size}!"
        h_seq = read_fasta_file(filepath_fasta)
        create_isoforms(h_seq, nil)
      end
    end
    
    
    #### get source types
    
    h_source_types = {}
    SourceType.all.map{|e| h_source_types[e.name] = e.id}
    
    
    Organism.all.select{|o| true}.each do |organism|

      puts "Loading #{organism.name} data..."
      
      #      name = organism.name.downcase.split(" ").join("_")
      name = organism.taxid.to_s
      puts "Reading mappings..."
      
      #### read mapping to refseq and ipi
      h_mappings={
        :refseq => {},
        :ipi => {},
	:mgi => {},
        :rgd => {},
	:pombase => {},
	:eupathdb => {},
        :ensembl_prot => {}
      }
      
      h_mappings.keys.each do |source|
        filepath=dir + (name + "." + source.to_s + ".txt")
	if File.exists?(filepath)
          puts filepath
          File.open(filepath, 'r') do |f|
            headers = f.readline.split(/\t/)
            while (l = f.gets) do
              tab = l.chomp.split(/\t/)
              h_mappings[source][tab[0]]||=[]
              h_mappings[source][tab[0]].push(tab[1])
            end
          end
        end
      end

      ### read ipi history
      h_reverse_ipi ={}
      h_mappings[:ipi].each_key do |ac|
        h_mappings[:ipi][ac].each do |ipi|
          h_reverse_ipi[ipi]=ac
        end
      end

      if File.exists?(dir + (name + ".ipi_history.txt"))      
        File.open(dir + (name + ".ipi_history.txt")) do |f|
          header =  f.readline
          while (l = f.gets) do
            tab  = l.chomp.split(/\t/)
            h_mappings[:ipi][h_reverse_ipi[tab[3]]].push(tab[0]) if h_reverse_ipi[tab[3]]
          end
        end
      end
      puts "Loading proteins..."
      
      load_proteins(name, dir, organism, h_mappings, h_source_types)
      
      # get all proteins
      proteins = Protein.all
      h_proteins = {}
      proteins.map{|p| 
        h_proteins[p.up_ac]=p.id; 
      }
	
      puts "Loading isoforms..."
      lines =[]
      File.open(dir + (name + ".fa")) do |f|
        lines = f.read.split(/\n/)
      end
      
      h_seq={}
      ac=''	
      lines.each do |l|
        if m=l.match(/^>(.+)/)
          line = m[1]
          fields = line.split("|")
          ac = fields[1]
          if h_seq[ac]
            puts "error with #{ac}"
          else	
            h_seq[ac]=''
          end	
        else
          h_seq[ac]+=l
        end
      end

      create_isoforms(h_seq, nil);
      
    end
    
  end
  
end


