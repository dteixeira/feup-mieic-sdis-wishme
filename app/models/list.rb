class List < ActiveRecord::Base

  belongs_to :user, :class_name => 'User'
  has_many :items, :class_name => 'Item', :dependent => :destroy
  attr_accessible :description, :id, :name, :private, :sha1_id, :user_id

  # Hash related stuff
  before_create :set_hash

  def set_hash
    begin token = SecureRandom.urlsafe_base64(12) end while
      List.where(:sha1_id => token).exists? self.sha1_id = token
  end

  def to_param
    sha1_id
  end

end
