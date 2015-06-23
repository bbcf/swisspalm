class OrthoSource < ActiveRecord::Base
  has_and_belongs_to_many :orthologues
  
  attr_accessible :name  
end
