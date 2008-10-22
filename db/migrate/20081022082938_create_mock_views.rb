class CreateMockViews < ActiveRecord::Migration
  def self.up
    create_table :mock_views do |t|
      t.string   :mock_id,         :null => false
      t.string   :user_id,         :null => false
      t.datetime :viewed_at,       :null => false
      t.integer  :reply_count,     :null => false, :default => 0
      t.datetime :last_replied_at
    end
    add_index :mock_views, [:user_id, :last_replied_at]
    add_index :mock_views, [:mock_id, :user_id], :unique => true
  end

  def self.down
    drop_table :mock_views
  end
end
