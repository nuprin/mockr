class Comment < ActiveRecord::Base
  belongs_to :author,
    :class_name => "User"
  belongs_to :feeling

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

  def mock
    Mock.find_by_id(self.mock_id || self.parent.mock_id)
  end

  def self.most_recent_comment_for(mock)
    Comment.find :first, :conditions => {:mock_id => mock.id},
                 :order => "created_at DESC"
  end

  def box_attribute
      return "box=\"#{x}_#{y}_#{width}_#{height}\"" if x && y && width && height
  end

end
