class CreateFeelings < ActiveRecord::Migration
  def self.up
    create_table :feelings do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :feelings
  end
end
