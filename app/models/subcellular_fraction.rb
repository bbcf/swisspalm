class SubcellularFraction < ActiveRecord::Base

  has_many :studies

  # attr_accessible :title, :body
  attr_accessible :name, :obsolete
end
