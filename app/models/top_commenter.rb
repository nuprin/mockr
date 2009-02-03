class TopCommenter < ActiveRecord::Base
  belongs_to :user
  def self.top?(user)
    self.exists?(:user_id => user.id)
  end
end
