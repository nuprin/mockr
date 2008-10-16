class Comment < ActiveRecord::Base
  belongs_to :author,
    :class_name => "User"
  belongs_to :feeling
  belongs_to :mock

  # TODO: Returns the set of comments.
  def children
    [
      Comment.new(:text => "whatevs", :created_at => 3.minutes.ago, 
                  :author => User.new),
      Comment.new(:text => "whatevs", :created_at => 1.minute.ago, 
                  :author => User.new),
    ]
  end

  def self.stubbed_comments
    @happy_feeling = Feeling.new(:name => "happy")
    @sad_feeling = Feeling.new(:name => "sad")
    [
      Comment.new(:text => "whatevs", :created_at => Time.now, 
                  :author => User.new, :feeling => @happy_feeling),
      Comment.new(:text => "whatevs", :created_at => Time.now, 
                  :author => User.new, :feeling => @sad_feeling),
      Comment.new(:text => "whatevs", :created_at => Time.now, 
                  :author => User.new, :feeling => @happy_feeling),
      Comment.new(:text => "whatevs", :created_at => Time.now, 
                  :author => User.new, :feeling => @happy_feeling),
    ]
  end
end
