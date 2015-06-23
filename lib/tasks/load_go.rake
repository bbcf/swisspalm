namespace :swisspalm do

  desc "Load go data"
  task :load_go, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    
    ### open file

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'

    Organism.all.each do |o|

      #      name = o.name.downcase.split(" ").join("_")
      
      file = dir + (o.taxid.to_s + ".go")

      if File.exists?(file)
      
        #FB      FBgn0043467     064Ya           GO:0048149      FB:FBrf0131396|PMID:11086999    IMP             P       064Ya           gene_product    taxon:7227      20060803        FlyBase
        
        content = []
        File.open(file, 'r') do |f|
          content=f.readlines
        end
        
        list_associations=[]
        list_fields=['tag', 'protein_id', 'code', 'go_term', 'unknown', 'code2', 'code3', 'code4', 'type', 'taxon', 'date', 'source']
        
        content.each_index do |i|
          
          tmp=content[i].chomp.split(/\t/)
          if !tmp[0].match(/^!/) 
            h_tmp ={} 
            if tmp[14] and tmp[12].match(/taxon:#{o.taxid}/)
              #puts tmp[1]
              proteins = RefProtein.find(:all, :conditions => {:value => [tmp[1], tmp[2]]}).map{|e| e.protein}.uniq.select{|p| p.organism_id == o.id}
              protein = (proteins.size == 1) ? proteins[0] : nil
              go_term = GoTerm.find(:first, :conditions => {:acc => tmp[4]})
              #	puts go_term.id
              #puts "protein_id"
              #puts proteins.size
              if protein and go_term
                
                ## update go_term in_flybase                                                                                                                                                              
                go_term.update_attribute(:in_swisspalm, true)
                
                h_tmp={
                :protein_id => protein.id,
                  :go_term_id => go_term.id,
                  :parent => false
                }
                
                assoc = ProteinGoAssociation.find(:first, :conditions => h_tmp)
                if !assoc
                  assoc = ProteinGoAssociation.new(h_tmp)
                  assoc.save
                end
                
                parent_go_terms = GoTerm.find(
                                              GoRelation.find(:all, :conditions => {:relationship_type_id => [1, 18], :term2_id => go_term.id}).map{|e| e.term1_id}
                                              )
                
                h_terms={}
                h_terms[go_term.id]=1
                
                while (parent_go_terms and parent_go_terms.size > 0)
                  
                  
                  parent_go_terms.reject{|e| h_terms[e.id]}.each do |go_term|
                    h_terms[go_term.id]=1
                    #	puts gene.id.to_s + '-' + go_term.id.to_s
                    h_tmp={
                      :protein_id => protein.id,
                      :go_term_id => go_term.id
                    }
                    
                    assoc = ProteinGoAssociation.find(:first, :conditions => h_tmp)
                    if !assoc
                      h_tmp[:parent] = true
                      assoc = ProteinGoAssociation.new(h_tmp)
                      assoc.save
                    end
                    
                    ## update go_term in_flybase
                    go_term.update_attribute(:in_swisspalm, true)
                  end
                  
                  #	puts parent_go_terms.map{|e| e.id}.join(",")      
                  parent_go_terms = GoTerm.find(
                                                GoRelation.find(:all, :conditions => {:relationship_type_id => [1, 18], :term2_id => parent_go_terms.map{|e| e.id}}).map{|e| e.term1_id}
                                                ).reject{|e| h_terms[e.id]}
                
                  #	puts parent_go_terms.map{|e| e.id}.join(",")
                  
                end
                #puts "done " + gene.id.to_s
              else
                puts tmp[1]
              #  puts go_term.id
                puts proteins.size         
                
              end
            end
          end
          
        end
      end
    end
    
  end
end
