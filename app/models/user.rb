class User < ActiveRecord::Base
  has_many :awards
  has_many :discussions,
    :conditions => "reply_count > 0",
    :order      => "last_replied_at DESC",
    :class_name => "MockView"

  named_scope :with_first_name, lambda {|first_name| 
    {:conditions => ["name LIKE '%s%%'", first_name]}
  }

  def first_name
    name.split.first
  end

  def real?
    !self.id.nil?
  end
  
  def unread_comments_for(mock)
    last_viewed_at = MockView.last_viewed_at(mock, self)
    if last_viewed_at
      comment_ids = self.subscribed_comment_ids(mock)
      comments = 
        Comment.about(mock).in_reply_to(comment_ids).since(last_viewed_at)
      Comment.find(comments.map(&:parent_id))
    else
      Comment.about(mock)
    end
  end

  # Returns the set of comments that the user is interested in tracking
  # new replies to.
  def subscribed_comment_ids(mock)
    comments = Comment.by(self).about(mock).all(:select => "id, parent_id")
    comments.map do |c|
      c.parent_id || c.id
    end
  end
end
