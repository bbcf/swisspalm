class HitValue < ActiveRecord::Base

  belongs_to :value_type
  belongs_to :hit

   attr_accessible :value_type_id, :hit_id, :value
end
