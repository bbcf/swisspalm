class Organism < ActiveRecord::Base

  has_many :studies
  has_many :proteins
  has_many :go_term_enrichments
  has_many :palmitome_entries

  # attr_accessible :title, :body
  attr_accessible :name, :up_tag, :taxid, 
  :go_url_part, :kingdom, :has_proteins, 
  :has_hits, :shortname, :common_name,  :ensembl_assembly, :ensemblgenomes_section, 
  :nber_cys_main_isoform,
  :nber_cys_in_disulfides,
  :nber_predicted_cys_main_isoform,
  :nber_predicted_cys_in_disulfides_main_isoform,
  :nber_proteins_with_disulfide,
  :nber_proteins_with_predicted_cys_main_isoform,
  :nber_prot_with_predicted_cys_main_isoform_without_false_pos,
  :topo_json,
  :prot_common_in_palmitomes_json, :prot_diff_in_palmitomes_json,
  :nber_cys_main_isoform_val,
  :nber_cys_in_disulfides_val,
  :nber_predicted_cys_main_isoform_val,
  :nber_predicted_cys_in_disulfides_main_isoform_val,
  :nber_proteins_with_disulfide_val,
  :nber_proteins_with_predicted_cys_main_isoform_val,
  :nber_prot_with_predicted_cys_main_isoform_without_false_pos_val,
  :topo_json_val,
  :prot_common_in_palmitomes_json_val, :prot_diff_in_palmitomes_json_val

end
