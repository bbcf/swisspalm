class RefIsoform < ActiveRecord::Base

  belongs_to :isoform
  belongs_to :source_type

  attr_accessible :isoform_id, :value, :source_type_id

end
