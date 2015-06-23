class ProteinGroup < ActiveRecord::Base

  has_many :hit_protein_groups

#  has_and_belongs_to_many :hits
  has_many :protein_group_values

   attr_accessible :hit_list_id, :protein_group_id


end
