class Verb < ActiveRecord::Base

  belongs_to :verb_type

   attr_accessible :verb_type_id, :name, :description
end
