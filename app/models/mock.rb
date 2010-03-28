class Mock < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  belongs_to :mock_list

  has_many :comments, :order => "created_at DESC"

  named_scope :recent, lambda {|limit| {:order => "id DESC", :limit => limit}}
  named_scope :with_author_and_project_data,
              :include => [:author, {:mock_list => :project}]
  
  has_attached_file :image,
    :styles => {
      :thumb  => "150x150#" # 150x150 thumbnail
    },
    :url  => "/mocks/:id/:basename-:style.:extension",
    :path => ":rails_root/public/mocks/:id/:basename-:style.:extension"

  validates_presence_of :author, :image_file_name, :mock_list, :version

  before_validation do |mock|
    mock.assign_version if mock.version.nil?
  end

  def attach_mock_list_if_necessary!(project_id)
    if !self.mock_list_id
      project = Project.find(project_id)
      ml = project.mock_lists.create(:title => project.default_mock_list_title)
      self.mock_list_id = ml.id
    end
  end

  def assign_version
    self.version = self.inferred_version
  end

  def inferred_version
    if self.mock_list
      previous_iterations_count = self.mock_list.mocks.size
      previous_iterations_count + 1
    else
      1
    end
  end

  def project
    self.mock_list.project
  end
  
  def title
    "#{self.mock_list.title} #{self.version}"
  end

  def filtered_comments(filter, user)
    conditions = {:mock_id => self.id, :parent_id => nil}
    if filter.to_i > 0
      conditions.merge!(:author_id => filter.to_i)
    elsif filter
      conditions.merge!(:feeling => filter)
    end
    Comment.all(:conditions => conditions)
  end

  def next
    self.class.first(:conditions => {
      :mock_list_id => self.mock_list_id,
      :version => self.version + 1
    })
  end

  def prev
    self.class.first(:conditions => {
      :mock_list_id => self.mock_list_id,
      :version => self.version - 1
    })
  end

  def happy_count
    Comment.happy.about(self).count
  end

  def sad_count
    Comment.sad.about(self).count
  end

  # A mock is "fresh" if there are new comments since the user last viewed.
  def fresh?(user)
    if user.real?
      last_viewed_at = MockView.last_viewed_at(self, user)
      !last_viewed_at || (self.updated_at > last_viewed_at)
    else
      false
    end
  end

  def author_feedback
    comments.group_by(&:author).to_a.map do |author, coms|
      [author, coms.size]
    end.sort_by do |author, count|
      author.name
    end
  end
  
  def deliver(email)
    Notifier.deliver_new_mock(self, email)
  end
end
