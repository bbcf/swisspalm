class ProteinGroupValue < ActiveRecord::Base

  belongs_to :protein_group
  belongs_to :value_type

   attr_accessible :protein_group_id, :value, :value_type_id
end
