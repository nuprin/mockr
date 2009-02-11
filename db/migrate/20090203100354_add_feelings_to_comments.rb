class AddFeelingsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :feeling, :string, :length => 32
    Comment.all.each do |comment|
      if comment.feeling_id
        name = Feeling.find(comment.feeling_id).name
        comment.update_attribute(:feeling, name)
      end
    end
  end

  def self.down
    remove_column :comments, :feeling
  end
end
