namespace :swisspalm do

  desc "Find best orthologue from OrthoDB (internal)"
  task :find_best_orthologue, [:version] do |t, args|

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
    
    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
    
    
    puts "Get proteins..."
    h_proteins = {}
    #  proteins = Protein.all.select{|e| e.has_hits == true}
    proteins = Protein.all #(Protein.find(:all, :conditions => {:is_a_pat => true}) | Protein.find(:all, :conditions => {:is_a_pat => false}) | Protein.find(:all, :conditions => {:has_hits => true}))
    proteins.map{|e| h_proteins[e.id] = e}
    
    #    proteins.select{|p| p.is_a_pat == true or p.is_a_pat == false or p.has_hits == true}.select{|p| p.up_id == 'CALX_HUMAN'}.each do |p|
    proteins.select{|p| p.is_a_pat == true or p.is_a_pat == false or p.has_hits == true}.each do |p|
      #      puts 'bla'
      
    #  gene_names = p.ref_proteins.select{|e| e.source_type.name =='gene_name'}.map{|e| e.value}
     
      oma_homologue_ids = OmaPair.find(:all, :conditions => {:protein_id1 => p.id}).map{|e| e.protein_id2} | OmaPair.find(:all, :conditions => {:protein_id2 => p.id}).map{|e| e.protein_id1} 
      oma_homologue_ids.uniq!
      
      orthodb_groups = OrthodbAttr.find(:all, :conditions => {:protein_id => p.id}).map{|e| e.orthodb_group_id}.uniq
      orthodb_attrs = OrthodbAttr.find(:all, :conditions => {:orthodb_group_id => orthodb_groups})
      h_orthodb_attrs = {}
      orthodb_attrs.map{|e| h_orthodb_attrs[e.protein_id]||=[]; h_orthodb_attrs[e.protein_id].push(e)}
      #orthodb_homologue_ids = orthodb_attrs.map{|e| e.protein_id}.reject{|e| e == p.id}.uniq
      # homologues = (homologue_ids.size > 0) ? Protein.find(homologue_ids) : []
      
      
      h_done_species={}
      #orthodb_attrs.select{|e| p.organism != e.protein.organism}.sort{|a, b| h_orthodb_attrs[b.protein_id].size <=> h_orthodb_attrs[a.protein_id].size}.each do |orthodb_attr|
      orthodb_homologue_ids =  h_orthodb_attrs.keys.select{|e| h_proteins[e] and p.organism_id != h_proteins[e].organism_id}.sort{|a, b| h_orthodb_attrs[b].size <=> h_orthodb_attrs[a].size}
      
      h_homologues = {'OMA' => oma_homologue_ids, 'OrthoDB' => orthodb_homologue_ids}
      ['OrthoDB', 'OMA'].each do |source_name|

        source = OrthoSource.find_by_name(source_name)

        h_homologues[source_name].each do |homologue_id|
          #homologue = orthodb_attr.protein
          homologue = h_proteins[homologue_id]
          #puts "#{homologue.up_id} : #{h_orthodb_attrs[homologue_id].size}"
          if source_name != 'OrthoDB' or !h_done_species[homologue.organism.id]
            
            #            puts h_orthodb_attrs[homologue.id].size
            
            ### search swissprot entries with at least one identical gene name if the protein has no known hit and if the protein has a hit                              
            #homologue = h_proteins[homologue_id]
            homologue_gene_names = homologue.ref_proteins.select{|e| e.source_type and e.source_type.name =='gene_name'}.map{|e| e.value}
            gene_names_matches = RefProtein.find(:all, :conditions => {:value => homologue_gene_names})
            sp_entries = Protein.find(:all, :conditions => {:id => gene_names_matches.map{|e| e.protein_id}.uniq, :organism_id => p.organism_id, :trembl => false})
            
            if p.hits.size > 0 and homologue.hits.size == 0 and sp_entries.size == 1
              #  puts "bla -> " + sp_entries.size.to_s + " => " + sp_entries[0].to_json     
              new_homologue = sp_entries[0]
            end
            
            h_best_orthologue = {
              :protein_id1 => p.id,
              :protein_id2 => homologue.id
            }
            h_best_orthologue2 = {
              :protein_id1 => homologue.id,
              :protein_id2 => p.id
            }
            
            best_orthologue = Orthologue.find(:first, :conditions => h_best_orthologue) 
            best_orthologue = Orthologue.find(:first, :conditions => h_best_orthologue2) if !best_orthologue
            
            if !best_orthologue
              #  puts "no best orthologue found for #{homologue.up_id}"
              if source_name == 'OMA' or !h_done_species[homologue.organism.id] or !h_orthodb_attrs[homologue.id] or h_done_species[homologue.organism.id]==h_orthodb_attrs[homologue.id].size
                #    puts "create! #{h_done_species[homologue.organism.id]}"
                # h_orthodb_best_orthologue[:ortho_source_id]=2
                best_orthologue = Orthologue.new(h_best_orthologue)
                best_orthologue.save
                h_done_species[homologue.organism.id]=h_orthodb_attrs[homologue.id].size if source_name == 'OrthoDB' 
              end
            else
              #   puts  orthodb_best_orthologue.to_json
              h_done_species[homologue.organism.id]=h_orthodb_attrs[homologue.id].size if source_name == 'OrthoDB' and h_orthodb_attrs[homologue.id]
            end
            	
            best_orthologue.ortho_sources << source if best_orthologue and !best_orthologue.ortho_sources.include?(source) 

          end
        end
      end
      
    end

    
  end
end
