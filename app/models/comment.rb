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


  named_scope :about, lambda {|mock| {:conditions => {:mock_id => mock.id}}}
  named_scope :by, lambda {|author| {:conditions => {:author_id => author.id}}}
  named_scope :happy, :conditions => {:feeling_id => Feeling.happy.id}
  named_scope :in_reply_to, lambda {|parent_id|
    {:conditions => {:parent_id => parent_id}}
  }
  named_scope :recent, :order => "created_at DESC"
  named_scope :sad, :conditions => {:feeling_id => Feeling.sad.id}
  named_scope :since, lambda {|time| 
    {:conditions => ["created_at >= ?", time]}
  }

  validates_presence_of :text, :if => Proc.new { |comment| 
      comment.parent
    }
  validates_presence_of :author
  validates_presence_of :feeling, :if => Proc.new { |comment|
      comment.parent.nil? && comment.text.blank?
    }

  def siblings
    self.parent_id ? self.parent.children : []
  end
  
  after_create do |comment|
    discussions = MockView.discussions_relevant_to(comment)
    discussions.each do |discussion|
      discussion.reply_count += 1
      discussion.last_replied_at = comment.created_at
      discussion.save!
    end
  end

  def box_attribute
    if x && y && width && height
      "box=\"#{x}_#{y}_#{width}_#{height}\"" 
    else
      ""
    end
  end

end
