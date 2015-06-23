class Hit < ActiveRecord::Base

  has_many :reactions
  has_many :hit_protein_groups

  has_and_belongs_to_many :techniques
  #  has_and_belongs_to_many :protein_groups

  belongs_to :hit_list
  belongs_to :protein
  belongs_to :isoform
  belongs_to :study
  has_many :hit_values
  has_many :sites
  has_many :history_sites

  attr_accessible :protein_id, :study_id, :isoform_id, :hit_list_id, :validator_id, :curator_id

end
