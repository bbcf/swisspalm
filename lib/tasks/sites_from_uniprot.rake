namespace :swisspalm do

  desc "Sites from uniprot"
  task :sites_from_uniprot, [:version] do |t, args|
    
    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"
    
    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'
    require 'hpricot'
    include Fetch
    
    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'

      
    Organism.all.select{|e| e.id==7 }.each do |organism|
      puts "=====>" + organism.name
      name = organism.name.downcase.split(" ").join("_")
      #      doc = Nokogiri::XML(dir + (name + '.xml'))# { |f| Hpricot(f) }
      #	puts File.new(dir + (name + '.xml')).size
      if File.exists?(dir + (name + '.xml')) and  File.new(dir + (name + '.xml')).size > 0
        doc = open(dir + (name + '.xml')) { |f| Hpricot(f) }     
        
        doc.search("entry").each do |entry|
          up_ac = entry.at("accession").innerHTML
          
          ### get PAT in features
          h_pat = {}
          features = entry.search("feature")
          #	puts features.size
          features.each do |feature|
            #S-palmitoyl cysteine; by ZDHHC5
            #          puts feature['description']
            if feature['description'] and m = feature['description'].match(/^S-palmitoyl cysteine; by (.+)/)
              identifiers =  m[1].split(/;? /).reject{|e| e == 'AND'}
              
              enzymes = []
              identifiers.each do |identifier|
                ref_proteins = RefProtein.find(:all, :conditions => ["source_type_id = 1 and lower(value) = ?", identifier.downcase])
                enzymes += ref_proteins.map{|r| r.protein}.select{|p| p.organism_id == organism.id}
              end
              pos = feature.at("location").at("position")['position']
              h_pat[pos.to_i] = enzymes.uniq
            end
          end
          
          entry.search("reference").each do |ref|
            scope = ref.at("scope").innerHTML
            if m = scope.match(/^PALMITOYLATION AT (.+?) BY (.+)/) or m = scope.match(/^PALMITOYLATION AT (.+)/)
              # puts "->" + ref.at("scope").innerHTML
              # puts m[1]
              pos_list = m[1].split(/;? /).reject{|e| e == 'AND'}.select{|e| e.match(/CYS/)}
              pos_list.each do |pos|
                # puts pos
              end
              
              ### enzyme known
              enzymes = []
              if m[2]
                identifiers = m[2].split(/;? /).reject{|e| e == 'AND'}
                # puts identifiers.join(',')
                identifiers.each do |identifier|
                  ref_proteins = RefProtein.find(:all, :conditions => ["source_type_id = 1 and lower(value) = ?", identifier.downcase])
                  enzymes += ref_proteins.map{|r| r.protein}.select{|p| p.organism_id == organism.id}
                end
                # puts enzymes.uniq.map{|p| p.up_ac}.join(',')
              end
              
              ### create study
              #            puts "--->" + ref.to_yaml + "<---"	
              citation = ref.at("citation")
              #            puts citation.innerHTML
              
              #### replace the load of title, authors and year by fetching in pubmed directly
              #	    title = citation.at("title").innerHTML
              #	    author_list = citation.at("authorlist")
              #            authors = author_list.search("person") if author_list
              
              dbrefs = citation.search("dbreference")            
              pmid = dbrefs.select{|r| r['type']=='PubMed'}.first
              
              res = fetch_pubmed(pmid['id'])
              
              cell_type = nil
              source = ref.at("source")
              if source
                tissues = source.search("tissue")
                if tissues.size == 1 
                  tissue = tissues[0].innerHTML
                  cell_type =  CellType.find(:first, :conditions => {:name => tissue})
                  puts "WARNING: Tissue not found in database: " + tissue if !cell_type
                else
                  puts "WARNING: Several tissues: " + tissues.map{|t| t.innerHTML}.join(", ")
                end
              end
              
              if pos_list.size > 0 and pmid	
                h_study = {
                  :title => res[:title],
                  :authors => res[:authors], #(authors) ? (authors.first['name'] + ((authors.size > 1 ) ? ' et al.' : '')) : nil,
                  :year => res[:year], #citation['date'],
                  :pmid => pmid['id'],
                  :organism_id => organism.id,
                  :large_scale => false
                }
                puts h_study.to_json
                study = Study.find(:first, :conditions => {:pmid => pmid['id']})
                if !study
                  study = Study.new(h_study)
                  # puts study.to_json
                  study.save
                else
                  if cell_type
                    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!! UPDATE " + cell_type.id.to_s 
                    study.update_attributes({:cell_type_id => cell_type.id})
                    #puts bla.to_json
                    #puts study.errors.to_yaml
                  end
                end
              end
              puts study.to_json
              
              ### create hit
              if study
                protein = Protein.find_by_up_ac(up_ac)
                
                h_hit = {
                  :protein_id => protein.id,
                  :hit_list_id => nil,
                  :study_id => study.id,
                  :isoform_id => nil
                }
                
                hit = Hit.find(:first, :conditions => h_hit)
                if !hit
                  hit = Hit.new(h_hit)            
                  hit.save
                end
              end
              ### create sites and associated reactions
              
              if hit
                pos_list.each do |pos|
                  tab = pos.split("-")                
                  h_site={
                    :hit_id => hit.id, 
                    :pos => tab[1],
                    :in_uniprot => true
                  }
                  
                  site = Site.find(:first, :conditions => h_site)
                  if !site
                    site = Site.new(h_site)
                    if site.save
                    else
                      puts "Error:" + site.to_json + "\n" + site.errors.to_json
                    end
                  end
                  
                  enzymes.each do |enzyme|
                    h_reaction = {
                      :site_id => site.id,
                      :protein_id => enzyme.id
                    }
                    
                    reaction = Reaction.find(:first, :conditions => h_reaction)
                    if !reaction
                      reaction = Reaction.new(h_reaction)
                      reaction.save
                    end
                  end
                  
                  ### complementation with feature table
                  
                  if h_pat[site.pos]
                    h_pat[site.pos].each do |enzyme|
                      h_reaction = {
                        :site_id => site.id,
                        :protein_id => enzyme.id 
                      }
                      
                      reaction = Reaction.find(:first, :conditions => h_reaction)
                      if !reaction
                        reaction = Reaction.new(h_reaction)
                        reaction.save
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
  end
end

