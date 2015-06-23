class ValueType < ActiveRecord::Base

  has_many :hit_values
  
   attr_accessible :name, :display_by_default
end
