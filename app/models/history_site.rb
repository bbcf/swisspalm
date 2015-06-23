class HistorySite < ActiveRecord::Base
  # attr_accessible :title, :body
  
  attr_accessible :site_id, :pos, :hit_id, :organism_id, :cell_type_id, :subcellular_fraction_id, 
  :required_mod, :in_uniprot, :created_at, :curator_id, :validator_id, :user_id, :technique_ids, :reaction_ids, :uncertain_pos
  
end
