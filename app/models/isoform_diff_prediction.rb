class IsoformDiffPrediction < ActiveRecord::Base
   attr_accessible :protein_id, :isoform_ids, :pos_isoforms, :nber_isoforms_pred, :nber_isoforms_total, :pos_ali
end
