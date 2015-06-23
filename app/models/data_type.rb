class DataType < ActiveRecord::Base

  has_many :vocabs
  
  attr_accessible :description, :name, :tag, :url_link, :url_download, :obj, :id_field, :name_field, :description_field, :condition
end
