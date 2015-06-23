class Reaction < ActiveRecord::Base
  
  belongs_to :site
  belongs_to :hit
  belongs_to :protein
  

  
  attr_accessible :site_id, :hit_id, :protein_id, :validator_id, :curator_id, :is_a_pat

end
