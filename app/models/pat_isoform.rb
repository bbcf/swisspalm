class PatIsoform < ActiveRecord::Base

belongs_to :isoform

   attr_accessible :isoform_id, :homology_group
end
