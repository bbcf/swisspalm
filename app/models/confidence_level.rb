class ConfidenceLevel < ActiveRecord::Base


  has_many :hit_lists
  # attr_accessible :title, :body
end
