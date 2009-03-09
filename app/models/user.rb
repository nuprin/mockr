class User < ActiveRecord::Base
  has_many :awards
  has_many :comments, :foreign_key => :author_id
  has_many :discussions,
    :conditions => "reply_count > 0",
    :order      => "last_replied_at DESC",
    :class_name => "MockView"

  named_scope :active, :conditions => {:active => true}
  named_scope :with_first_name, lambda {|first_name| 
    {:conditions => ["name LIKE '%s%%'", first_name]}
  }

  def self.sorted
    self.active.sort_by(&:name)
  end

  def first_name
    name.split.first
  end
  
  def awarded_feelings
    self.awards.map(&:feeling)
  end

  def real?
    !self.id.nil?
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
