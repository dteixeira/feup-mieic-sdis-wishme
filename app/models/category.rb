class Category < ActiveRecord::Base

  has_many :items, :class_name => 'Item', :dependent => :destroy
  attr_accessible :id, :name

end
