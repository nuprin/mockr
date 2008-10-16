class Comment < ActiveRecord::Base
  belongs_to :author,
    :class_name => "User"
  belongs_to :feeling
  belongs_to :mock

  has_many :children,
    :class_name => 'Comment',
    :foreign_key => 'parent_id'

  def author
    User.new(:name => "Fako")
  end
end
