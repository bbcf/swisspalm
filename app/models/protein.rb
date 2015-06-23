class Protein < ActiveRecord::Base

  belongs_to :organism
  has_many :refseq_proteins
  has_many :ipi_proteins
  has_many :isoforms
  has_many :gene_names
  has_many :hits
  has_many :ref_proteins
  has_many :protein_go_associations
  has_many :reactions
  has_and_belongs_to_many :diseases
  has_and_belongs_to_many :subcellular_locations
  has_and_belongs_to_many :topologies
  has_and_belongs_to_many :protein_complexes
  
  attr_accessible  :up_ac, :up_id, 
  :description, :organism_id, :has_hits, :has_hits_ortho, :trembl, :user_id, :nber_studies, :nber_all_studies, :is_a_pat, :nber_cys_max, 
  :validated_dataset,
  :nber_technique_categories_labuser, :nber_technique_categories_public, :has_hits_targeted,
  :fp_label, :fp_chem, :fp_go


end
