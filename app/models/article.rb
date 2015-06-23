class Article < ActiveRecord::Base

  #  has_many :studies

  attr_accessible :title, :authors, :year, :pmid

end
