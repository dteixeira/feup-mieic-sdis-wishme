class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|

      t.integer   :id
      t.integer   :category_id,   :null => false
      t.integer   :list_id,       :null => false
      t.string    :sha1_id,       :null => false, :default => ""
      t.string    :name,          :null => false, :default => ""
      t.string    :description
      t.string    :img_hash
      t.boolean   :private,       :null => false, :default => false

      t.timestamps
    end

    add_index :items, :sha1_id, :unique => true
  end
end
