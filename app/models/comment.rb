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

  validates_presence_of :text, :if => Proc.new { |comment| 
      comment.parent
    }
  validates_presence_of :author
  validates_presence_of :feeling, :unless => Proc.new { |comment|
      !comment.parent.nil?
    }

  def box_attribute
      return "box=\"#{x}_#{y}_#{width}_#{height}\"" if x && y && width && height
  end

end
