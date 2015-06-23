class RefProtein < ActiveRecord::Base

  belongs_to :protein
  belongs_to :source_type
  
  attr_accessible  :protein_id, :value, :source_type_id

end
