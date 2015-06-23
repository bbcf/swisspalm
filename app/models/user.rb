class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
#  devise :database_authenticatable, :registerable,
#         :recoverable, :rememberable, :trackable, :validatable

  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,
  :token_authenticatable, :confirmable, :lockable, :timeoutable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

#  has_and_belongs_to_many :uploads

#  after_create :update_emails
#  after_create :update_uploads

#  def update_emails
#    if e = Email.find_by_email(email)
#      e.update_attribute(:user_id, id)
#    end
#  end
  
end
