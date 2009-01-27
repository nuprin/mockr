class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false

      t.timestamps
    end

    ['Kristján Pétursson', 'Brad Fults',
     'Chris Chan',
     'Jimmy Kittiyachavalit', 'Kevin Ball',
     'Keith Rarick', 'Jen Kelly',
     'Josh Adams', 'Joe Green',
     'Sean Parker', 'Randall Winston',
     'Matt Mahan', 'Susan Gordon',
     'Sara Koch', 'Josh Williams'].each do |name|
       User.create(:name => name)
     end
  end

  def self.down
    drop_table :users
  end
end
