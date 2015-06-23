class Orthologue < ActiveRecord::Base
  has_and_belongs_to_many :ortho_sources

  attr_accessible :protein_id1, :protein_id2 
end
