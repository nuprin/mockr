class DropTopCommenters < ActiveRecord::Migration
  def self.up
    drop_table :top_commenters
  end

  def self.down
    create_table "top_commenters", :force => true do |t|
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
