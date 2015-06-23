class OrthodbAttr < ActiveRecord::Base
  
  belongs_to :protein

  attr_accessible :protein_id, :orthodb_group_id, :level, :best_orthologue

end
