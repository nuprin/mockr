class PopulateFbuidsForUsers < ActiveRecord::Migration
  def self.up
    {'Kristján Pétursson' => 204381,
     'Brad Fults' => 3301657,
     'Chris Chan' => 203070,
     'Jimmy Kittiyachavalit' => 1225510,
     'Kevin Ball' => 704626712,
     'Jen Kelly' => 1218195,
     'Josh Adams' => 874880011,
     'Joe Green' => 42,
     'Sean Parker' => 207996,
     'Matt Mahan' => 828,
     'Susan Gordon' => 501438,
     'Sara Koch' => 500095281,
     'Josh Williams' => 762975524,
     'Aaron Sittig' => 1208381}.each do |name, fbuid|
       u = User.find_by_name(name)
       if u.nil?
         u = User.create!(:name => name, :fbuid => fbuid)
       else
         u.update_attribute(:fbuid, fbuid)
       end
    end
  end

  def self.down
  end
end
