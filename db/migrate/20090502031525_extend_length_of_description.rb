class ExtendLengthOfDescription < ActiveRecord::Migration
  def self.up
    change_column :mocks, :description, :string, :limit => 2000 
  end

  def self.down
    change_column :mocks, :description, :string, :limit => 255
  end
end
