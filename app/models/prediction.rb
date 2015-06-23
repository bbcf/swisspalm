class Prediction < ActiveRecord::Base

  belongs_to :isoform
  belongs_to :cys_env

   attr_accessible :isoform_id, :pos, :cp_cluster, :cp_score, :cp_high_cutoff, :cp_medium_cutoff, :cp_low_cutoff, :cp_all_cutoff, :cys_env_id, :pp_score, :compatible_loc, :palmpred, :psipred_ss, :uniprot_ss, :hc_pred
end
