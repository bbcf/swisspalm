class HitSite < ActiveRecord::Base

  belongs_to :hit
  belongs_to :protein
  
  attr_accessible :transferase, :hit_id, :pos, :required_mod 
end
