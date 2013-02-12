class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|

      t.integer     :id
      t.integer     :user_id,     :null => false
      t.string      :sha1_id,     :null => false, :default => ""
      t.string      :name,        :null => false, :default => ""
      t.string      :description
      t.boolean     :private,     :null => false, :default => false

      t.timestamps

    end

    add_index :lists, :sha1_id, :unique => true

  end
end
