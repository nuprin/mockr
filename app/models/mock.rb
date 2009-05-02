class Mock < ActiveRecord::Base

  MOCK_PATH = "public/images/mocks"

  has_many :comments, :order => "created_at DESC"

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

  def full_path
    "#{MOCK_PATH}/#{self.path}"
  end
  
  # url and image_url are hacks until I can figure out how to get normal
  # routes working in rich text emails.
  def url
    "http://mockr/#{URI.encode(self.path)}"
  end

  def image_url
    "http://mockr/images/mocks/#{URI.encode(self.path)}"
  end

  def self.for(path)
    full_path = "#{MOCK_PATH}/#{path}"
    unless File.exist?(full_path)
      raise MockDoesNotExist.new(full_path)
    end

    if File.directory?(full_path)
      raise MockPathIsDirectory.new(Mock.last_mock_for(path))
    end

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

  def image_path
    "mocks/#{path}"
  end

  def dir
    path.split('/')[0...-1].join('/')
  end

  def filename
    path.split('/').last
  end

  def next
    my_index = ordered_feature.index(self)
    ordered_feature[my_index + 1]
  end

  def prev
    my_index = ordered_feature.index(self)
    return nil if my_index == 0
    ordered_feature[my_index - 1]
  end

  def <=>(other)
    self.revision <=> other.revision
  end

  def revision
    /\w+-(\d+)\.(jpg|gif|png)/ =~ filename ? $1.to_i : -1
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

  def self.ordered_feature(feature)
    feature_filenames(feature).map do |sibling_path|
      Mock.for(sibling_path)
    end.sort_by(&:title)
  end

  def ordered_feature
    Mock.ordered_feature(dir)
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

  def self.last_mock_for(feature)
    self.ordered_feature(feature).last
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
end
