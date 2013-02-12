class Item < ActiveRecord::Base

  belongs_to :category, :class_name => 'Category'
  belongs_to :list, :class_name => 'List'
  attr_accessible :id, :list_id, :category_id, :description, :img_hash, :name, :private, :sha1_id

  # Hash related stuff
  before_create :set_hash

  def set_hash
    begin token = SecureRandom.urlsafe_base64(12) end while
      Item.where(:sha1_id => token).exists? self.sha1_id = token
  end

  def to_param
    sha1_id
  end

end
