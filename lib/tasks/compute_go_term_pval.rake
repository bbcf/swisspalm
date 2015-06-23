namespace :swisspalm do

  desc "Compute GO term p-value"
  task :compute_go_term_pval, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    include Basic

    class Integer
      def fact
        (1..self).reduce(:*) || 1
      end
    end
    

    ['validated', 'all'].each do |dataset| 

      [1, 2].each do |organism_id|
        
        organism = Organism.find(organism_id)
        proteins = Protein.find(:all, :conditions => {:organism_id => organism_id})
        
        palm_proteins = proteins.select{|e| e.has_hits==true}
        palm_proteins.select!{|e| e.validated_dataset == true} if dataset == 'validated'
        
        #      go_term_ids = ProteinGoAssociation.find(:all, :joins => 'join proteins on (proteins.id = protein_go_associations.protein_id)',
        #                                               :conditions => {:proteins => {:organism_id => organism_id}}).map{|e| e.go_term_id}.uniq
        
        
        organism.go_term_enrichments.select{|e| e.validated_dataset == ((dataset == 'validated') ?  true : false)}.sort{|a, b| a.id <=> b.id}.each do |e|
          
          if e.nber_palm > 0
            
            a= e.nber_palm-1        
            b= e.nber_prot
            #palm_proteins.size - e.nber_palm
            c= palm_proteins.size - e.nber_palm
            d= proteins.size - e.nber_prot
            
            #        pval = 0
            #     nom = ((a+b).fact * (c+d).fact * (a+c).fact * (b+d).fact)
            #     size = (nom.to_s.size) - 10          
            #     pval = (nom/10**size).to_f/((a.fact*b.fact*c.fact*d.fact*(a+b+c+d).fact)/10**size)	
            
            #       else
            #         #        puts a.fact
            #         
            nom = (((a>0) ? lim_fact(b+1, a+b) : 1) * 
                   ((c>0) ? lim_fact(d+1, c+d) : 1) * 
                   (b+d).fact * 
                   ((a>0) ? lim_fact(c+1,a+c) : 1))
            size = (nom.to_s.size) - 10
            pval = (nom/10**size).to_f/((a.fact*(a+b+c+d).fact)/10**size)
            
            #        end
            #          puts "(((#{a+b}).fact * (#{c+d}).fact * (#{a+c}).fact * (#{b+d}).fact)/10**#{size}).to_f/((#{a}.fact*#{b}.fact*#{c}.fact*#{d}.fact*(#{a+b+c+d}).fact)/10**#{size})"
            #	puts pval1
            puts pval
            #        pval = (nCr(palm_proteins.size,b) * nCr(proteins.size,c)) / nCr(proteins.size + palm_proteins.size, e.nber_palm + e.nber_prot)
            
            e.update_attribute(:pval, pval)
          end
        end
      end

    end
  end
end
