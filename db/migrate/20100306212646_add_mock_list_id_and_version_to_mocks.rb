class AddMockListIdAndVersionToMocks < ActiveRecord::Migration
  def self.up
    add_column :mocks, :mock_list_id, :integer
    add_column :mocks, :version, :integer
    add_column :mocks, :author_id, :integer
    change_column :mocks, :path, :string
    add_index :mocks, :mock_list_id
  end

  def self.down
    remove_index :mocks, :mock_list_id
    remove_column :mocks, :mock_list_id
    remove_column :mocks, :version
  end
end
