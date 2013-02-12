class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  #:recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :registerable, :token_authenticatable
  before_save :ensure_authentication_token

  has_many :lists, :class_name => 'List', :dependent => :destroy
  has_many :items, :through => :lists

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation, :authentication_token
end
