class RemoveFeelingIdFromComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :feeling_id
  end

  def self.down
    add_column :comments, :feeling_id, :integer
  end
end
