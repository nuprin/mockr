class User < ActiveRecord::Base
  def first_name
    name.split.first
  end

  def real?
    !self.id.nil?
  end
  
  def discussions
    MockView.discussions_for(self)
  end
  
  def unread_comments_for(mock)
    last_viewed_at = MockView.last_viewed_at(mock, self)
    if last_viewed_at
      comment_ids = self.subscribed_comment_ids(mock)
      Comment.about(mock).in_reply_to(comment_ids).since(last_viewed_at).all
    else
      Comment.about(mock).all
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
