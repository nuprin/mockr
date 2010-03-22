class Mock < ActiveRecord::Base

  MOCK_PATH = "public/images/mocks"

  belongs_to :author, :class_name => "User"
  belongs_to :mock_list

  has_many :comments, :order => "created_at DESC"

  named_scope :recent, lambda {|limit| {:order => "id DESC", :limit => limit}}

  has_attached_file :image,
    :styles => {
      :small  => "100x>",    # 100 pixel, width-limited
      :thumb  => "150x150#", # 150x150 thumbnail
      :medium => "200x>",    # 200 pixel, width-limited
    },
    :url  => "/mocks/:id/:basename-:style.:extension",
    :path => ":rails_root/public/mocks/:id/:basename-:style.:extension"

  validates_presence_of :author, :image_file_name, :mock_list, :version

  class MockDoesNotExist < StandardError
    attr_reader :path
    def initialize(path)
      @path = path
    end
    def to_s
      @path
    end
  end

  class MockPathIsDirectory < StandardError
    attr_reader :mock
    def initialize(mock)
      @mock = mock
    end
    def to_s
      @mock
    end
  end

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

  def full_path
    "#{MOCK_PATH}/#{self.path}"
  end
  
  def title
    "#{self.mock_list.title} #{self.version}"
  end

  def self.for(path)
    full_path = "#{MOCK_PATH}/#{path}"
    mock = Mock.find_by_path(path)
    if mock.nil?
      clean_filename = path.split('/').last.
                            split('.').first.
                            gsub(/[^\w]/, ' ').
                            titleize
      mock = Mock.create(:path => path, :title => clean_filename)
    end
    mock
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

  def dir
    path.split('/')[0...-1].join('/')
  end

  def filename
    path.split('/').last
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

  def <=>(other)
    self.revision <=> other.revision
  end

  def revision
    /\D+(\d+)\.(jpg|gif|png)/ =~ self.filename ? $1.to_i : -1
  end

  def self.feature_filenames(feature)
    Dir.glob("#{MOCK_PATH}/#{feature}/*").select do |filename|
      filename.ends_with?('jpg') ||
      filename.ends_with?('png') ||
      filename.ends_with?('gif')
    end.map do |path|
      path.split('/')[3..-1].join('/')
    end
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
      if comment = most_recent_comment
        return last_viewed_at.nil? || (comment.created_at > last_viewed_at)
      end
    end
    false
  end

  def self.features
    Dir.glob("#{MOCK_PATH}/*").map {|path| path.split('/').last }
  end

  def self.folders
    Dir.glob(Mock::MOCK_PATH + "/*").map do |dir|
      subdirectories =
        Dir.glob(dir + "/*").map do |subdir|
          subdir.gsub(dir + "/", "")
        end.select do |subdir|
          !subdir.match(/[.]+/)
        end.sort
      [dir.gsub(Mock::MOCK_PATH + "/", ""), subdirectories]
    end.sort_by(&:first)
  end

  def most_recent_comment
    Comment.about(self).recent.first
  end

  def self.recently_commented_mocks
    mock_ids =
      Comment.recent.all(:select => "distinct mock_id", :limit => 9).
      map(&:mock_id)
    mock_ids.map do |mock_id|
      mock = Mock.find(mock_id)
      [mock, mock.most_recent_comment]
    end.sort do |(m1, c1), (m2, c2)|
      c1.created_at <=> c2.created_at
    end.reverse
  end

  def self.sorted_features
    @sorted_features ||= self.features.sort
  end

  def author_feedback
    comments.group_by(&:author).to_a.map do |author, coms|
      [author, coms.size]
    end.sort_by do |author, count|
      author.name
    end
  end
  
  def feature
    return nil if self.path.blank?
    dirs = self.path.split("/")
    dirs.first(dirs.length - 1).join(" ").strip
  end
  
  def title_without_revision
    self.title.gsub(/\s+\d+$/, '')
  end

  def self.migrate!
    self.set_all_versions!
    self.set_all_projects!
    self.set_all_mock_lists!
    self.set_all_mocks!
    self.i_authored_all_mocks!
    self.translate_mocks_to_attachments!
    true
  end
  
  def self.set_all_versions!
    Mock.all.each do |m|
      version = m.revision == -1 ? 1 : m.revision
      m.update_attribute(:version, version)
    end
  end

  def self.i_authored_all_mocks!
    u = User.find_by_name("Chris Chan")
    self.update_all "author_id = #{u.id}" if u
  end

  def self.set_all_projects!
    Mock.features.each do |title|
      Project.create(:title => title)
    end
  end
  
  def self.set_all_mock_lists!
    self.set_all_mock_lists_via_subdirectories!
    self.set_all_mock_lists_via_title!
  end
  
  def self.set_all_mock_lists_via_subdirectories!
    Mock.folders.each do |project_title, mock_list_titles|
      project = Project.find_by_title(project_title)
      mock_list_titles.each do |mock_list_title|
        begin
          MockList.create!(:title => mock_list_title, :project_id => project.id)
        rescue ActiveRecord::StatementInvalid
          
        end
      end
    end    
  end
  
  def self.set_all_mock_lists_via_title!
    Mock.all.each do |mock|
      next unless mock.feature
      project = Project.find_by_title(mock.feature)
      if project
        begin
          MockList.create!(:title => mock.title_without_revision,
                           :project_id => project.id)
          puts "Created mock list for #{mock.id}!"
        rescue
          puts "Couldn't create mock list for #{mock.id}."
        end
      else
        puts "Couldn't find project for #{mock.id}."
      end
    end
  end

  def inferred_project
    dirs = self.path.split("/")
    dirs.select{|dir| !dir.blank?}.first
  end

  def self.set_all_mocks!
    Mock.all.each do |mock|
      puts "Setting mock for #{mock.id}..."
      project = Project.find_by_title(mock.inferred_project)
      if project
        ml = MockList.find_by_title_and_project_id mock.title_without_revision, 
                                                   project.id
        if !ml
          alt_title = mock.feature.gsub(/#{mock.inferred_project}\s+/, '')
          ml = MockList.find_by_title_and_project_id alt_title, 
                                                     project.id
        end
        if ml
          puts "Success"
          mock.update_attribute(:mock_list_id, ml.id)
        else
          puts "Fail"
        end
      end
    end
  end  
  
  def self.translate_mocks_to_attachments!
    Mock.all.each do |mock|
      puts "Translating mock #{mock.id}..."
      begin
        mock.image = File.new(mock.full_path)
        mock.save!
      rescue Errno::ENOENT, Errno::EISDIR
        puts "Couldn't find mock for #{mock.id}..."
        mock.destroy
      rescue ActiveRecord::RecordInvalid
        puts "Mock #{mock.id} still has no mock list..."
      end
    end
  end
end
