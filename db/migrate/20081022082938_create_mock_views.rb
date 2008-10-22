class CreateMockViews < ActiveRecord::Migration
  def self.up
    create_table :mock_views do |t|
      t.string :user_id, :null => false
      t.string :mock_id, :null => false

      t.timestamps
    end
    add_index :mock_views, [:mock_id, :user_id], :unique => true
  end

  def self.down
    drop_table :mock_views
  end
end
