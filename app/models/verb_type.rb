class VerbType < ActiveRecord::Base
  has_many :verbs

   attr_accessible :name, :description
end
