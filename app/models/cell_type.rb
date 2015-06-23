class CellType < ActiveRecord::Base

  has_many :studies
  belongs_to :cellosaurus_cell_type

  # attr_accessible :title, :body

  attr_accessible :name, :cellosaurus_cell_type_id

end
