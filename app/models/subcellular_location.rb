class SubcellularLocation < ActiveRecord::Base
  has_and_belongs_to_many :proteins

   attr_accessible :name, :status

end
