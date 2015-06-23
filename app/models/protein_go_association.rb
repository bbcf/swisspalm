class ProteinGoAssociation < ActiveRecord::Base

  belongs_to :protein
  belongs_to :go_term

  # attr_accessible :title, :body
  attr_accessible :protein_id, :go_term_id, :parent



end
