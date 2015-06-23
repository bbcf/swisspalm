class Technique < ActiveRecord::Base
  
  has_and_belongs_to_many :studies
  has_and_belongs_to_many :sites
  has_and_belongs_to_many :hits
  belongs_to :technique_class
  belongs_to :technique_category

  # attr_accessible :title, :body
  attr_accessible :name, :large_scale, :site_characterization, :parent_id, :technique_category_id, :technique_class_id

end
