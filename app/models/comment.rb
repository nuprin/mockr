class Comment < ActiveRecord::Base
  belongs_to :author,
    :class_name => "User"
  belongs_to :feeling
  belongs_to :mock

  belongs_to :parent,
    :class_name => 'Comment'
  has_many :children,
    :class_name => 'Comment',
    :foreign_key => 'parent_id'

  validates_presence_of :text
  validates_presence_of :author

end
