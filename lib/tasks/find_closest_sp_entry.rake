namespace :swisspalm do

  desc "Find closest sp entry"
  task :find_closest_sp_entry, [:version] do |t, args|

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

    puts "Get proteins..."
    proteins =  Protein.all
    h_proteins = {}
    
    proteins.map{|e| h_proteins[e.id]=e}
    
    puts "Get gene names..."
    ref_proteins = RefProtein.find(:all, :conditions => {:source_type_id => 1})
    h_gene_names_by_prot = {}
   
    ref_proteins.each do |rp|
      h_gene_names_by_prot[rp.protein_id]||=[]
      h_gene_names_by_prot[rp.protein_id].push(rp.value)
    end

    h_gene_names_str_by_prot = {}
    h_prots_by_gene_name_str = {}

    h_gene_names_by_prot.each_key do |protein_id|
      #gene_names_str = h_gene_names_by_prot[protein_id].sort.join(",")
      h_gene_names_by_prot[protein_id].sort.each do |gene_name_str|
        h_gene_names_str_by_prot[protein_id]= gene_name_str
        h_prots_by_gene_name_str[gene_name_str]||= []
        h_prots_by_gene_name_str[gene_name_str].push(protein_id)
      end
    end
    
    puts "Start searching..."
    
    proteins.select{|p| p.trembl == true and h_gene_names_by_prot[p.id]}.each do |p|
      gene_names = h_gene_names_by_prot[p.id] #p.ref_proteins.select{|rp| rp.source_type and rp.source_type.name == 'gene_name' }.map{|e| e.value}.sort
      # proteins = Protein.find(:all, :conditions => {:trembl => false, :organism_id => p.id, :description => p.description}).select{|p2|
      proteins2 = []
      gene_names.each do |gn|
        proteins2.push(h_prots_by_gene_name_str[gn].map{|pid| h_proteins[pid]}.select{|p2| p2.organism_id == p.organism_id and p2.trembl == false and h_gene_names_by_prot[p2.id]})
      end
      proteins2.flatten!.uniq!
        #.select{|p2|
        #        gene_names == h_gene_names_by_prot[p2.id].sort #p2.ref_proteins.map{|rp| rp.source_type and rp.source_type.name == 'gene_name'}.map{|e| e.value}.sort
        #      }
        
        
      if proteins2.size ==1
        #        puts "update #{p.up_id}..."
        p.update_attribute(:closest_sp_protein_id, proteins2.first.id)
      elsif proteins2.size > 1
        list_up_ids = proteins2.map{|e| e.up_id}.join(',')
        puts "#{p.up_id}: #{proteins2.size}"# SwissProt entries (#{list_up_ids})"
      end
    end
    
  end
end
