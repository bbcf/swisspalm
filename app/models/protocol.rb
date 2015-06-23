class Protocol < ActiveRecord::Base

  belongs_to :user
  
  attr_accessor :file
  attr_accessible :name, :description, :file

end
