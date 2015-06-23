module LoadData

  include Fetch
  include Parse

  protected

  def read_protein_features(organism, h_feature_types)

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'    
    files = ["#{organism.taxid}.all.xml", "#{organism.taxid}_db_update_entries.xml"].reverse

    res = {}

    files.each do |file|

      filepath_xml = dir + file
      if File.exists?(filepath_xml)
        puts "read #{filepath_xml}..."
        
        doc = open(filepath_xml) { |f| Hpricot(f) }
        doc.search("entry").each do |entry|
          trembl = (entry['dataset'] == 'Swiss-Prot') ? false : true
          accessions = entry.search("accession")
          up_ac = accessions.first.innerHTML
          protein = Protein.find_by_up_ac(up_ac)
          res[protein.id]=[]
#          puts "-> " + up_ac
          
          entry.search("feature").each do |feature|
            if h_feature_types[feature['type']] and location = feature.at("location")
              start = (location.at("begin")) ? location.at("begin")['position'] : location.at("position")['position']
              stop = (location.at("end")) ? location.at("end")['position'] : location.at("position")['position']
#              puts up_ac + ": " + [start, stop].join(", ") 
              
              h_feature = {
                :feature_type_id => h_feature_types[feature['type']].id,
                :protein_id => protein.id,
                :start => start,
                :stop => stop,
                :description => feature['description'],
                :status => feature['status']
              }

              if h_feature_types[feature['type']].name == 'sequence conflict'
                h_feature[:variant]={
                  :original => (ori = feature.at("original")) ? ori.innerHTML : nil,
                  :variation => (variation = feature.at("variation")) ? variation.innerHTML : nil
                }
              end
              
              res[protein.id].push(h_feature)
              
            end
          end          
          
        end
      end

    end
    return res
  end

  def create_protein(h_res, identifier_type, identifier)

    protein = nil
    if h_res[:protein]
      protein = Protein.find(:first, :conditions => {:up_ac => h_res[:protein][:up_ac]})
      if !protein
        protein = Protein.new(h_res[:protein])
        protein.save
      else
        protein.update_attributes({
                                    :up_id => h_res[:protein][:up_id],
                                    :description => h_res[:protein][:description],
                                    :trembl => h_res[:protein][:trembl]
                                  })
      end
      h_res[:list_gene_names].each do |gene_name|
        h_ref_protein = {
          :source_type_id => SourceType.find_by_name('gene_name').id,
          :value => gene_name,
          :protein_id => protein.id
        }
        ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
        if !ref_protein
          ref_protein =  RefProtein.new(h_ref_protein)
          ref_protein.save
        end
      end
      #      identifier_type == 'UniProt AC' if identifier_type == 'isoform_identifier'
      if identifier_type and identifier and identifier_type != 'isoform_identifier'
        source_type =  SourceType.find(:first, :conditions => {:name => identifier_type})
        if source_type
          h_ref_protein = {
            :source_type_id => (source_type) ? source_type.id : nil,
            :value => identifier,
            :protein_id => protein.id
          }
          ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
          if !ref_protein
            ref_protein = RefProtein.new(h_ref_protein)
            ref_protein.save
          end
        end
      end
      if identifier_type != 'UniProt AC'
        h_ref_protein = {
          :source_type_id => SourceType.find(:first, :conditions => {:name => 'UniProt AC'}),
          :value => protein.up_ac,
          :protein_id => protein.id
        }
        ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
        if !ref_protein
          ref_protein = RefProtein.new(h_ref_protein)
          ref_protein.save
        end
      end
      if identifier_type !='UniProt ID'
        h_ref_protein = {
          :source_type_id => SourceType.find(:first, :conditions => {:name => 'UniProt ID'}),
          :value => protein.up_id,
          :protein_id => protein.id
        }
        ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
        if !ref_protein
          ref_protein = RefProtein.new(h_ref_protein)
          ref_protein.save
        end
      end
      
    end
   
    return protein

  end


  def create_isoforms(h_seq, fixed_protein)

    h_up_ac = {}
    h_seq.each_key do |k|
      tab = k.split("-")
      h_up_ac[tab[0]] ||= []
       h_up_ac[tab[0]].push(k) #=h_seq[k]
    end

    h_up_ac.each_key do |up_ac|
      
      protein = Protein.find_by_up_ac(up_ac)
      
      if protein
        
        ### reset latest_version for all isoform of a protein (we estimate that we retrieve all isoforms at once
        protein.isoforms.select{|i| (i.main == true) ? h_up_ac[up_ac].include?(up_ac) : h_up_ac[up_ac].include?(up_ac + "-" + i.isoform.to_s)}.each do |i|
          i.update_attribute(:latest_version, false)
        #  puts "isoform update latest version false #{i.id}"  
        end
        
        h_up_ac[up_ac].each do |k|
          
          iso = -1
          tab = k.split("-")
          #  ac = tab[0]
          iso = tab[1] if tab.size == 2
          
          #      protein = Protein.find_by_up_ac(ac) if !fixed_protein
                
          h_iso={
            :protein_id => protein.id,
            :isoform => iso,
            :seq => h_seq[k],
            :latest_version => true
          }
          
          isoform = Isoform.find(:first, :conditions => {:protein_id => protein.id, :seq => h_seq[k]})
          if !isoform
            isoform = Isoform.new(h_iso)
            isoform.save
          else
            isoform.update_attributes(:latest_version => true, :isoform => iso)
          end
        end
        
        ##### get the new object
        protein = Protein.find(protein.id)

        ### identify main isoform                                                                
        #  isoforms = protein.isoforms.select{|i| i.latest_version == true}.sort{|a, b| a.isoform <=> b.i
        isoforms = protein.isoforms.select{|isoform| isoform.latest_version == true}.sort{|a, b| a.isoform <=> b.isoform}
       # puts "isoforms_all: " + protein.isoforms.map{|i| i.id}.join(",")
       # puts "isoforms: " + isoforms.map{|i| i.id}.join(",")
        if isoforms.size > 0 and isoforms[0].isoform == -1      
          flag=0      
          (1 .. isoforms.size-1).to_a.each do |i|
            if isoforms[i].isoform != i
            #  puts "Update #{isoforms[0].to_json} with ISOFORM => #{i}"
              isoforms[0].update_attributes({:isoform => i, :main => true})
              flag=1
              break;
            end
          end
          
          if flag==0
            i = isoforms.size
          #  puts "Update #{isoforms[0].to_json} with ISOFORM => #{i}"
            isoforms[0].update_attributes({:isoform => i, :main => true})
          end
        end

      end
    end
  end

  def load_protein(identifier, organism, identifier_type, has_hits)
    
    ### fetch directly by uniprot AC                                                                                                                                                                      
    h_res = fetch_uniprot_entry(identifier)
    
    if !h_res[:protein]
      ### make a query                                                                                                                                                                                      
      organism_txt = (organism) ? "+AND+taxonomy%3a%22#{organism.taxid}%22" : '' 
      url = "http://www.uniprot.org/uniprot/?query=accession%3a#{identifier}%0D%0A#{organism_txt}&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism-id,length"
      puts "URL => #{url}"
      # logger.debug(url)                                                                                                                                                                                                      
      res = `wget -q -O - '#{url}'`.split("\n")
      sleep(1)
      if res.size <= 1
        url = "http://www.uniprot.org/uniprot/?query=#{identifier}%0D%0A#{organism_txt}&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism-id,length"
        puts "URL => #{url}"
        # logger.debug(url)
        res = `wget -q -O - '#{url}'`.split("\n")
        sleep(1)
      end
      if res.size > 1
            
        tab = res[1].split("\t")
        if !organism
          organism=Organism.find_by_taxid(tab[6])
        end
        h_res[:protein]={
          :up_ac => tab[0],
          :up_id => tab[1],
          :description => tab[4],
          :organism_id => (organism) ? organism.id : nil,
          :has_hits => has_hits,
          #          :is_a_pat => nil,
          :trembl => (tab[3] == 'unreviewed') ? true : false
        }
        h_res[:list_gene_names] = tab[5].split(' ');
      end
    else
      h_res[:protein][:organism_id]= organism.id
    end

    protein = nil
    if h_res[:protein][:up_ac] and h_res[:protein][:up_ac].size == 6
      protein = create_protein(h_res, identifier_type, identifier)
    end
    
    if protein
      
      h_seq = fetch_uniprot_seq(protein.up_ac)    
      create_isoforms(h_seq, protein)
  
    end
    return protein
  end
  
  def load_all_proteins(query, organism, is_a_pat)

    organism_txt = (organism) ? "+AND+taxonomy%3a%22#{organism.taxid}%22" : ''
    url = "http://www.uniprot.org/uniprot/?query=#{query}%0D%0A#{organism_txt}&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism-id,length"
    res = `wget -q -O - '#{url}'`.split("\n")
    sleep(1)
    list_proteins = []
    if res.size > 1
      (1 .. res.size-1).to_a.each do |i|
        tmp_organism = organism
        tab = res[i].split("\t")
        if !tmp_organism
          tmp_organism=Organism.find_by_taxid(tab[6])
        end
        if tmp_organism
          h_res={}
          h_res[:protein]={
            :up_ac => tab[0],
            :up_id => tab[1],
            :description => tab[4],
            :organism_id => tmp_organism.id,
            :has_hits => nil,
            :is_a_pat => is_a_pat,
            :trembl => (tab[3] == 'unreviewed') ? true : false
          }
          h_res[:list_gene_names] = tab[5].split(' ');
          
          protein = create_protein(h_res, nil, nil)         
          if protein
            list_proteins.push(protein)
            h_seq = fetch_uniprot_seq(protein.up_ac)
            create_isoforms(h_seq, protein)
          end
        end
      end
    end
    return list_proteins
  end
  

  def read_fasta_file(file)

    h_seq = {}
    File.open(file) do |f|
      lines = f.read.split(/\n/)
      h_seq = parse_fasta(lines)
    end

    return h_seq

  end

  def read_data(file_content)
  
    column_headers = []
    data = []
    i=0
    puts "File content: #{file_content}"
    #logger.debug(file_content.to_json)
    file_content.each do |line|
      line.chomp!
 #     logger.debug line
      if i == 0                                                                                                                                               
        column_headers = line.split("\t")
      else
        data.push(line.split("\t"))
      end
      i+=1
    end

#    logger.debug data.to_json

    h_column_headers = {}
    (0 .. column_headers.size-1).to_a.map{|i| e = column_headers[i]; h_column_headers[e]=i}

    return {
      :data => data,
      :column_headers => column_headers,
      :h_column_headers => h_column_headers
    }

  end

  def load_protein_group_file(hit_list, protein_group_file_content, validated_prot_file_content)
    
    ### get hits
#    h_hit_id_by_protein_group = {}
    
#    hit_list.hits.each do |hit|
#      value = hit.hit_values.select{|hv| hv.value_type_id = protein_group_type_id}[0]
#      h_hit_id_by_protein_group[value]||=[]
#      h_hit_id_by_protein_group[value].push(hit)
#    end
    r_proteins = read_data(validated_prot_file_content)
    
    h_groups_by_hit = {}

    r_proteins[:data].each do |tab|
      protein_group = tab[r_proteins[:h_column_headers]['Protein group ID']]
      t = tab[0].split("-")
      up_ac = t[0]
      protein = Protein.find_by_up_ac(up_ac)
      if protein
        isoforms = protein.isoforms
        isoform = nil
        if t.size > 1
          isoform = isoforms.select{|i| i.isoform == t[1].to_i and i.latest_version == true}.first
        else
          isoform = isoforms.select{|i| i.main == true and i.latest_version == true}.first
        end
        hit = Hit.find(:first, :conditions => 
                       {
                         :hit_list_id => hit_list.id,
                         :protein_id => protein.id,
                         :isoform_id => (isoform) ? isoform.id : nil
                       })
        if hit
          h_groups_by_hit[hit.id]||={}
          h_groups_by_hit[hit.id][protein_group]= tab[r_proteins[:h_column_headers]['Identification case']]
        else
          puts "Hit not found for protein_id #{ protein.id} and isoform #{isoform.to_json}"
        end
      else
        puts "Not found protein for #{up_ac}."
      end
    end
    
    r = read_data(protein_group_file_content)
    
    ### get value types
    list_value_types = []
    (1 .. r[:column_headers].size - 1).to_a.each do |i|
      h = {
        :name => r[:column_headers][i]
      }
      puts  r[:column_headers][i]
      value_type = ValueType.find(:first, :conditions => h)
      list_value_types.push(value_type.id)
    end
    
    puts "List value type!!!!!!!!!!!!!!!!!:" + list_value_types.to_json

    r[:data].each do |row|
      #      hit_id =  h_hit_id_by_protein_group[row[0]]
      h={
        :hit_list_id => hit_list.id, 
        :protein_group_id => row[0]
      }
      protein_group = ProteinGroup.find(:first, :conditions => h)
      if !protein_group
        protein_group = ProteinGroup.new(h)
        protein_group.save
      end

      #### add association hits <-> protein_groups
      # hit
      
      list_value_types.each_index do |i|
        h = {
          :value => row[i+1],
          :protein_group_id => protein_group.id,
          :value_type_id => list_value_types[i]
        }
        
        protein_group_value = ProteinGroupValue.find(:first, :conditions => h)
        if !protein_group_value
          protein_group_value = ProteinGroupValue.new(h)
          protein_group_value.save
        end
      end

    end

    protein_group_type = ValueType.find_by_name("Protein group ID")
    protein_group_type_id = protein_group_type.id

    #    puts h_groups_by_hit.to_json
    
    hit_list.hits.each do |hit|
      if h_groups_by_hit[hit.id]
        h_groups_by_hit[hit.id].each_key do |group_id|
          h = {                      
            :protein_group_id => group_id,                
            :hit_list_id => hit_list.id                                              
          }     
          protein_group = ProteinGroup.find(:first, :conditions => h)
          
          h_hit_protein_group = {
            :protein_group_id => protein_group.id,
            :hit_id => hit.id,
            :identification_case => h_groups_by_hit[hit.id][group_id]
          }
          hit_protein_group = HitProteinGroup.find(:first, :conditions => h_hit_protein_group)
          if !hit_protein_group
            hit_protein_group = HitProteinGroup.new(h_hit_protein_group)
            hit_protein_group.save
          end
          #        hit.protein_groups << protein_group if !hit.protein_groups.include?(protein_group) #.include?(hit.protein_groups)
        end
      else
        puts "Cannot find groups for hit #{hit.id}"
      end
    end
    
  end

  
  def load_data_file(hit_list, file_content, organism_id, study_id)
    
    read_data_file( file_content, hit_list.identifier_type, organism_id, study_id)
    
    @hits.each_index do |i|
      h_hit = @hits[i]
      if @new_hits.include?(h_hit)
        hit = Hit.find(:first, :conditions => h_hit)
        if !hit
          hit = Hit.new(h_hit)
          hit_list.hits << hit 
        end
        @data_hits[i].each do |h_data|
#          h_data=@data_hits[i][j]
          value_type = ValueType.find(:first, :conditions => { :name => h_data[:header]})
          # if !value_type
          #   value_type = ValueType.new({ :name => h_data[:header]})
          #   value_type.save
          # end
          if ! ['Protein group ID', 'Identification case'].include?(value_type.name)
            puts h_data[:header] + " is not defined!!!!!!!!!!!!!!!!!!!!!!" if !value_type
            h = {
              :value_type_id => value_type.id,
              :hit_id => hit.id,
              :value => h_data[:value]
            }
            hit_value = HitValue.find(:first, :conditions => h)
            if !hit_value
              hit_value = HitValue.new(h)
              hit_value.save
            end
          end
        end
      end
      
    end
  end
  
  def read_data_file( file_content, identifier_type, organism_id, study_id)

    r = read_data(file_content)
    puts "number of lines: " + r[:data].size.to_s
    
    @data_hits=[]
    @hits=[]
    @new_hits=[]
    
    organism = Organism.find(organism_id)
    
    if organism
      
      @count_found = []
      @count_already_present = []
      @count_not_found = []
      if @hit_list
        @hits=@hit_list.hits.map{|hit| {
            :protein_id => hit.protein_id,
            :study_id => hit.study_id,
            :isoform_id => hit.isoform_id
          }
        }
      end
      @debug = ''
      r[:data].each do |row|
        ### create hit                                                                                                                                                                  
        m = row[0].match(/\s*(.+?)\s*$/)
        identifier = m[1]
        protein = nil
        isoform = nil
        
        ### first try to match a the level of isoform                                                                                                                                   
        ref = RefIsoform.find(:first, :conditions => {:value => identifier})
        if ref
          isoform = ref.isoform
          protein = isoform.protein if isoform
#          puts "Protein: " + protein.up_ac
        end
       
        
        ### if not                 
        if !protein
          if identifier_type == 'isoform_identifier'
            tab = identifier.split("-")
            puts "Identifier: " + identifier
            protein = Protein.find_by_up_ac(tab[0])
            if protein and tab.size == 1
              isoform = Isoform.find(:first, :conditions => {:main => true, :protein_id => protein.id, :latest_version => true})
            elsif protein
              isoform = Isoform.find(:first, :conditions => {:isoform => tab[1].to_i, :protein_id => protein.id, :latest_version => true})
            end
            puts isoform.to_yaml
          elsif identifier_type == 'up_ac'
            protein = Protein.find_by_up_ac(identifier)
          elsif identifier_type == 'up_id'
            protein = Protein.find_by_up_id(identifier)
          elsif ['gene_name', 'ipi', 'pombase'].include?(identifier_type)
            ref = RefProtein.find(:first,
                                  :joins => "join source_types on (source_types.id = source_type_id) join proteins on (proteins.id = protein_id)",
                                  :conditions => {:source_types => {:name => identifier_type}, :proteins =>{:organism_id => organism.id}, :value => identifier})
            
            protein = (ref) ? ref.protein : Protein.find_by_up_id(identifier + "_" + organism.up_tag)
          end
          if !protein
            refs = RefProtein.find(:all,
                                   :joins => "join proteins on (proteins.id = protein_id)",
                                   :conditions => ["proteins.organism_id = ? and lower(value) = ?",   organism.id ,  identifier.downcase])
            protein = refs.first.protein if refs.size == 1
          end
        end
        
        ### if not, do the same but trunking the identifier if it contains a . or -                                                                                                     
        if !protein and identifier.match(/[.\-]/)
          identifier_part =  identifier.split(/[\-.]/).first
          ref = RefProtein.find(:first,
                                :joins => "join proteins on (proteins.id = protein_id)",
                                :conditions => ["proteins.organism_id = ? and lower(value) = ?",   organism.id ,  identifier_part.downcase])
          protein = ref.protein if ref
          identifier = identifier_part
        end
        

        #### try to get the protein from a query on uniprot (get from trEMBL)                                                                                                           
        if !protein

          protein = load_protein(identifier, organism, identifier_type, true)
          
#          ### fetch directly by uniprot AC                                                                                                                                              
#          
#          h_res = Fetch.fetch_uniprot_entry(identifier)
#          
#          if !h_res[:protein]
#            ### make a query                                                                                                                                                                  
#            url = "http://www.uniprot.org/uniprot/?query=#{identifier}%0D%0A+AND+taxonomy%3a%22#{organism.taxid}%22&format=tab&columns=id,entry%20name,feature%28LIPIDATION%29,reviewed,protein%20names,genes,organism,length"
#            res = `wget -O - '#{url}'`.split("\n")
#            sleep(1)
#            if res.size > 1
#              tab = res[1].split("\t")
#              h_res[:protein]={
#                :up_ac => tab[0],
#                :up_id => tab[1],
#                :description => tab[4],
#                :organism_id => organism.id,
#                :has_hits => true,
#                :trembl => (tab[3] == 'unreviewed') ? true : false
#              }
#              h_res[:list_gene_names] = tab[5].split(' ');
#            end
#          else
#            h_res[:protein][:organism_id]= organism.id
#          end
#          
#          if h_res[:protein]
#            protein = Protein.find(:first, :conditions => {:up_ac => h_res[:protein][:up_ac]})
#            if !protein
#              protein = Protein.new(h_res[:protein])
#              protein.save
#            end
#            h_res[:list_gene_names].each do |gene_name|
#              h_ref_protein = {
#                :source_type_id => SourceType.find_by_name('gene_name').id,
#                :value => gene_name,
#               :protein_id => protein.id
#             }
#              ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
#              if !ref_protein
#                ref_protein =  RefProtein.new(h_ref_protein)
#                ref_protein.save
#              end
#            end
#            source_type =  SourceType.find(:first, :conditions => {:name => identifier_type})
#            h_ref_protein = {
#              :source_type_id => (source_type) ? source_type.id : nil,
#              :value => identifier,
#              :protein_id => protein.id
#            }
#            ref_protein = RefProtein.find(:first, :conditions => h_ref_protein)
#            if !ref_protein
#              ref_protein = RefProtein.new(h_ref_protein)
#              ref_protein.save
#            end
#            
#            h_seq = Fetch.fetch_uniprot_seq(protein.up_ac)
#            
#            h_seq.each_key do |k|
#              iso = -1
#              tab = k.split("-")
#              ac = tab[0]
#              iso = tab[1] if tab.size == 2
#              
#              h_iso={
#                :protein_id => protein.id,
#                :isoform => iso,
#                :seq => h_seq[k]
#              }
#              
#              isoform = Isoform.find(:first, :conditions => {:protein_id => protein.id, :seq => h_seq[k]})
#              if !isoform
#               isoform = Isoform.new(h_iso)
#                isoform.save
#              else
#                isoform.update_attributes(h_iso)
#                #  count+=1                                                                                                                                                                   
#              end
#              
#            end
#            
#            ### identify main isoform                                                                                                                                                         
#            
#            isoforms = protein.isoforms.sort{|a, b| a.isoform <=> b.isoform}
#            
#            if isoforms.size > 0 and isoforms[0].isoform == -1
#              
#              flag=0
#              
#              (1 .. isoforms.size-1).to_a.each do |i|
#                if isoforms[i].isoform != i
#                  isoforms[0].update_attributes({:isoform => i, :main => true})
#                  flag=1
#                  break;
#                end
#              end
#              
#              if flag==0
#                i = isoforms.size
#                isoforms[0].update_attributes({:isoform => i, :main => true})
#              end
#            end
#          end
#          
        end
        
        #### if the protein is found / created then add the protein to the hit_list                                                                                                           
        if protein
          #           isoform = protein.isoforms.select{|e| e.main == true}.first                                                                                                             
          h = {
            :protein_id => protein.id,
            :study_id => study_id,
            :isoform_id => (isoform) ? isoform.id : nil
          }

          if !@hits.include?(h)
            
            @hits.push(h)
            puts "add hit"
            list_h_data=[]
            puts "=>" + r[:column_headers].to_json
            (1 .. r[:column_headers].size - 1).to_a.each do |col|
              header = r[:column_headers][col]
              h_data = {
                :header => header,
                :value => row[col]
              }
              list_h_data.push(h_data)
              puts "add #{h_data.to_json}"
            end
            
            @data_hits.push(list_h_data)
           
            @new_hits.push(h)
            @count_found.push(identifier)
          else
            @count_already_present.push(identifier)
          end
        else
          @count_not_found.push(identifier)
        end
        
      end
    end
  end
  
  def load_uniprot_entries_from_xml(filepath_xml)

    list_proteins=[]
    
    doc = open(filepath_xml) { |f| Hpricot(f) }
    doc.search("entry").each do |entry|
      trembl = (entry['dataset'] == 'Swiss-Prot') ? false : true
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
      if organism
        gene = entry.at("gene")
        gene_names = (gene) ? gene.search("name").map{|e| e.innerHTML} : []
        
        h_res={}
        
        h_res[:protein]={
          :up_ac => up_ac,
          :up_id => up_id,
          :description => description,
          :organism_id => (organism) ? organism.id : nil,
          :has_hits => false,
          :trembl => trembl
        }
        h_res[:list_gene_names] = gene_names#.split(' ');
        if h_res[:list_gene_names] and  h_res[:list_gene_names].size > 0
          protein = create_protein(h_res, 'up_ac', up_ac)
          list_proteins.push(protein)
        end
      end
      
    end
    
    return list_proteins
    
  end
  
end
