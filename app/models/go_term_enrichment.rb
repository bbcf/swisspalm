class GoTermEnrichment < ActiveRecord::Base
  belongs_to :go_term
  belongs_to :organism
  
   attr_accessible   :nber_prot, :nber_palm, :enrichment, :go_term_id, :organism_id, :validated_dataset


end
