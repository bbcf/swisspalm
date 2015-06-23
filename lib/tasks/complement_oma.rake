namespace :swisspalm do
  
  desc "Complement OMA with gene names"
  task :complement_oma, [:version] do |t, args|

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
    Protein.all.each do |p| 	
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

    Protein.all.each do |p|
      if !h_done_prot[p.id]
        first_part_up_id=p.up_id.split("_")[0]
        h_proteins_by_gene_name[first_part_up_id] ||= []
        h_proteins_by_gene_name[ first_part_up_id].push(p.id)
        h_done_prot[p.id]=1
      end
    end

    puts "Write results..."
    h_proteins_by_gene_name.each_key do |gn|
      list_up_ids = h_proteins_by_gene_name[gn].map{|p_id| h_proteins[p_id] and h_proteins[p_id].up_id}.join(", ") 

      list = h_proteins_by_gene_name[gn]
      (0 .. list.size-2).each do |i|
	(i+1 .. list.size-1).each do |j|

          if h_proteins[list[i]].organism_id !=  h_proteins[list[j]].organism_id
            
            h_oma_pair = {
              :protein_id1 => list[i],
              :protein_id2 => list[j]
            }
            oma_pair = OmaPair.find(:first, :conditions => {
                                      :protein_id1 => list[i],
                                      :protein_id2 => list[j]})
            if !oma_pair
              oma_pair = OmaPair.find(:first, :conditions => {
                                        :protein_id1 => list[j],
                                        :protein_id2 => list[i]})
            end
            if !oma_pair
              oma_pair= OmaPair.new(h_oma_pair)
              puts "add pair #{h_proteins[list[i]].up_id}, #{h_proteins[list[j]].up_id} : " +  oma_pair.to_json 
              oma_pair.save
            end
          else
            # do nothing yet with paralogues
          end
        end
      end

      puts "#{gn} => #{list_up_ids}"
    end    
    
    
  end
end
