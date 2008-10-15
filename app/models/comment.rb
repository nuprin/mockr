class Comment < ActiveRecord::Base
  belongs_to :author,
    :class_name => "User"
  belongs_to :feeling

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
