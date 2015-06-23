class Feature < ActiveRecord::Base
   attr_accessible :feature_type_id, :protein_id, :start, :stop, :description, :status, :original, :variation
end
