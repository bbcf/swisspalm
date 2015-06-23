namespace :swisspalm do

  desc "Compute GO term enrichments"
  task :compute_go_term_enrichments, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'

    [1, 2].each do |organism_id|
      [false, true].each do |validated_dataset|
        h_validated_dataset = (validated_dataset == true) ? {:validated_dataset => true} : {}
        
        #isoforms = Isoform.find(:all, 
        #                        :joins => 'join proteins on (proteins.id = isoforms.protein_id)',  
        #                        :conditions => {:proteins => {:organism_id => organism_id}} ) 
        #cysteines = Prediction.find(:all, :conditions => {:isoform_id => isoforms.map{|e| e.id}})
        #cys_envs = CysEnv.find(cysteines.map{|e| e.cys_env_id}.compact)
        
        proteins = Protein.find(:all, :conditions => {:organism_id => organism_id}.merge(h_validated_dataset))
                
        ### compute 
        # GoTerm.find(:all, 
        #            :joins => 'join protein_go_associations on (go_terms.id = isoforms.protein_id)',
        #            :conditions => ''
        #            ).each do |go_term|
        
        h_go_terms = {}
        proteins.each do |protein|
          protein.protein_go_associations.each do |association|
            if !h_go_terms[association.go_term_id]
              associations = ProteinGoAssociation.find(:all, :select => 'protein_go_associations.*, proteins.has_hits_public, proteins.validated_dataset', :joins => 'join proteins on (proteins.id = protein_go_associations.protein_id)',
                                                       :conditions => {:go_term_id => association.go_term_id, :proteins => {:organism_id => organism_id}#.merge(h_validated_dataset)
})
              if associations.size > 0
                palm_associations = associations.select{|a| #puts "#{a.protein_id}:#{a.has_hits_public}"; 	    
	a.has_hits_public == 't' and (validated_dataset == false or a.validated_dataset == 't')}
                puts "-->" + association.go_term_id.to_s
                puts 	palm_associations.size
                puts associations.size
                h = {
                  :go_term_id => association.go_term_id,
                  :organism_id => organism_id,
                  :validated_dataset => validated_dataset		
                }
                h_new = {
                  :nber_prot => associations.size,                                                           
                  :nber_palm => palm_associations.size,               
                  :validated_dataset => validated_dataset,
                  :enrichment => (palm_associations.size.to_f / associations.size.to_f),                                
                  :go_term_id => association.go_term_id,
                  :organism_id => organism_id
                }
                n = GoTermEnrichment.find(:first, :conditions => h)
                if !n
                  n = GoTermEnrichment.new(h_new)
                  n.save
                else
                  n.update_attributes(h_new)
                end
              end
              h_go_terms[association.go_term_id]=1;
            end            
          end
        end
      end
    end
  end
end
