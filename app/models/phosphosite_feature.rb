class PhosphositeFeature < ActiveRecord::Base
  belongs_to :phosphosite_type
  belongs_to :isoform

   attr_accessible :phosphosite_type_id, :isoform_id, :pos, :pubmed_ltp, :pubmed_ms2

end
