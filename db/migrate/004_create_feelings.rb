class CreateFeelings < ActiveRecord::Migration
  def self.up
    create_table :feelings do |t|
      t.string :name, :null => false
      t.string :path, :null => false

      t.timestamps
    end

    Feeling.create(:name => 'happy', :path => 'happy.gif')
    Feeling.create(:name => 'sad', :path => 'sad.gif')
  end

  def self.down
    drop_table :feelings
  end
end
