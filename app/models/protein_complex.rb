class ProteinComplex < ActiveRecord::Base

  has_and_belongs_to_many :proteins

  attr_accessible :id, :organism_id, :name, :nber_prot, :nber_prot_with_c, :nber_prot_validated_dataset, :nber_prot_palm, :nber_prot_predicted

end
