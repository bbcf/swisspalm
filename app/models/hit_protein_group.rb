class HitProteinGroup < ActiveRecord::Base

  belongs_to :hit
  belongs_to :protein_group
  
  attr_accessible :identification_case, :hit_id, :protein_group_id

end
