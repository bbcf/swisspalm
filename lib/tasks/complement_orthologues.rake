namespace :swisspalm do
  
  desc "Complement orthologues with gene names"
  task :complement_orthologues, [:version] do |t, args|

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
    h_proteins = {}
    Protein.all.select{|p| p.trembl == false}.each do |p| 	
      h_proteins[p.id]=p
    end

    puts "Get gene names..."
    h_proteins_by_gene_name = {}

    
    h_done_prot = {} ### get only the first gene_name
    #  RefProtein.find(:all, :conditions => {:source_type_id => 1}, :order => 'id').each do |gn|
    #     if !h_done_prot[gn.protein_id]
    #       h_proteins_by_gene_name[gn.value.upcase] ||= []
    #       h_proteins_by_gene_name[gn.value.upcase].push(gn.protein_id)
    #       h_done_prot[gn.protein_id]=1
    #     end

    Organism.all.each do |o|	
      puts "#{o.name}..."
      h_proteins_by_gene_name[o.id]={}
      
      #      o.proteins.select{|e| e.trembl == false}.each do |p|
      #  if !h_done_prot[p.id]  
      #  first_part_up_id=p.up_id.split("_")[0]
      
      gene_names = RefProtein.find(:all, :conditions => {:source_type_id => 1, :protein_id => o.proteins.select{|p| p.trembl == false}.map{|e| e.id}})
      gene_names.each do |gn|
        h_proteins_by_gene_name[o.id][gn.value] ||= []
        h_proteins_by_gene_name[o.id][gn.value].push(gn.protein_id) if !h_proteins_by_gene_name[o.id][gn.value].include?(gn.protein_id)
        #     h_done_prot[p.id]=1
      end
      # end
      #   end
    end
    
    ortho_source = OrthoSource.find_by_name('Gene names')

    puts "Write results..."
    h_proteins_by_gene_name.each_key do |organism_id|
      h_proteins_by_gene_name[organism_id].each_key do |gn|
        #      list_up_ids = h_proteins_by_gene_name[organism_id][gn].map{|p_id| h_proteins[p_id] and h_proteins[p_id].up_id}.join(", ") 
        
        list = h_proteins_by_gene_name[organism_id][gn]
        (0 .. list.size-2).each do |i|
          (i+1 .. list.size-1).each do |j|
            
            #          if h_proteins[list[i]].organism_id !=  h_proteins[list[j]].organism_id
            
            h_orthologue = {
              :protein_id1 => list[i],
              :protein_id2 => list[j]
            }
            orthologue = Orthologue.find(:first, :conditions => {
                                           :protein_id1 => list[i],
                                           :protein_id2 => list[j]})
            if !orthologue
              orthologue = Orthologue.find(:first, :conditions => {
                                             :protein_id1 => list[j],
                                             :protein_id2 => list[i]})
            end
            if !orthologue
              orthologue= Orthologue.new(h_orthologue)
              puts "add pair #{h_proteins[list[i]].up_id}, #{h_proteins[list[j]].up_id} : " +  orthologue.to_json 
              orthologue.save
              
              #add orthologues of p1 to p2 and vice versa

              orthologues_p1 = Orthologue.find(:all, :conditions => {
                                                 :protein_id1 => list[i]})
              orthologues_p2 = Orthologue.find(:all, :conditions => {
                                                 :protein_id1 => list[j]})
              [[list[j], orthologues_p1], [list[i], orthologues_p2]].each do |el|
                #                orthologue = nil
                el[1].each do |e|
                  h_orthologue = {
                    :protein_id1 => el[0],
                    :protein_id2 => e
                  }
                  orthologue2 = Orthologue.find(:first, :conditions => h_orthologue)
                  if !orthologue
                    orthologue2 = Orthologue.find(:first, :conditions => {
                                                    :protein_id1 => e,
                                                    :protein_id2 => el[0]})
                  end
                  if !orthologue2
                    orthologue2= Orthologue.new(h_orthologue)
                    #                    puts "add pair #{h_proteins[list[i]].up_id}, #{h_proteins[list[j]].up_id} : " +  orthologue.to_json
                    orthologue2.save
                    
                  end
                  orthologue2.ortho_sources << ortho_source if !orthologue2.ortho_sources.include?(ortho_source)
                end
              end
            end
            
            orthologue.ortho_sources << ortho_source if !orthologue.ortho_sources.include?(ortho_source)
            #else
            #  # do nothing yet with paralogues
            #end
          end
        end
#        puts "#{gn} => #{list_up_ids}"
      end 
    end   
    
    
  end
end
