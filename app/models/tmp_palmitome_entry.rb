class TmpPalmitomeEntry < ActiveRecord::Base

  attr_accessible :organism_id, :protein_id, 
  :hit_list_json, :orthologue_protein_ids, 
  :nber_palmitome_studies, :palmitome_study_ids, :targeted_study_ids, :targeted_study_ids_prot,
  :targeted_study_protein_ids, :technique_ids, :annotated_site_ids

end
