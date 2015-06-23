class Disease < ActiveRecord::Base
  has_and_belongs_to_many :proteins

   attr_accessible :disease_id, :acronyme, :name, :description
end
