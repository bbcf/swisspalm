class HitList < ActiveRecord::Base

  has_many :hits
  has_many :protein_groups
  belongs_to :confidence_level
  belongs_to :study
  belongs_to :file_type

  attr_accessible :confidence_level_id, :label, :file, :identifier_type, :study_id, :simulation, :file_type_id, :filename, :status_id
  attr_accessor :file, :simulation, :internal_study

end
