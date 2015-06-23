class GeneName < ActiveRecord::Base

  belongs_to :protein

   attr_accessible :name, :protein_id
end
