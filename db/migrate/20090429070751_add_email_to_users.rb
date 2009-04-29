class AddEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string
    User.all.each do |user|
      user.email = "#{user.first_name.downcase}@causes.com"
      user.save
    end
  end

  def self.down
    remove_column :users, :email
  end
end
