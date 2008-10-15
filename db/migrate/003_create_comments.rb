class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :mock_id, :null => false
      t.integer :author_id, :null => false
      t.integer :parent_id
      t.integer :feeling_id
      t.string  :text, :null => false, :limit => 1024
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
