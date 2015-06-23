class Vocab < ActiveRecord::Base
  belongs_to :data_type

   attr_accessible :data_type_id, :name, :description
end
