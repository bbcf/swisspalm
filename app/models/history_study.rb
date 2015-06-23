class HistoryStudy < ActiveRecord::Base
  # attr_accessible :title, :body

   attr_accessible :id, :study_id, :name, :pmid,
  :organism_id, :cell_type_id, :subcellular_fraction_id, :in_vitro,
  :large_scale, :hidden, :user_id, :created_at, :technique_ids

end
