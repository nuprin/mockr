class CreateMocks < ActiveRecord::Migration
  def self.up
    create_table :mocks do |t|
      t.string :path
      t.string :title
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :mocks
  end
end
