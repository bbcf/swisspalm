class GoTerm < ActiveRecord::Base

  has_many :protein_go_associations
  
  # attr_accessible :title, :body
end
