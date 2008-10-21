class Mock < ActiveRecord::Base

  MOCK_PATH = "public/images/mocks"

  has_many :comments,
    :order => "created_at DESC"

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

  def filtered_comments(filter)
    return comments if filter.blank?
    author_id = filter.to_i
    if author_id > 0
      return Comment.find(:all, :conditions => {:mock_id => self.id,
                                                :author_id => author_id})
    else
      feeling_id = Feeling.send(filter)
      return Comment.find(:all, :conditions => {:mock_id => self.id,
                                                :feeling_id => feeling_id})
    end
  rescue
    comments
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
    end.sort
  end
  def ordered_feature
    Mock.ordered_feature(dir)
  end

  def happy_count
    Comment.count(:conditions => {:mock_id => self.id,
                                  :feeling_id => Feeling.happy.id})
  end

  def sad_count
    Comment.count(:conditions => {:mock_id => self.id,
                                  :feeling_id => Feeling.sad.id})  end

  def self.features
    Dir.glob("#{MOCK_PATH}/*").map {|path| path.split('/').last }
  end

  def self.last_mock_for(feature)
    self.ordered_feature(feature).last
  end

  def most_recent_comment
    Comment.most_recent_comment_for(self)
  end

  # TODO [chris]: So messy.
  def self.recently_commented_mocks
    sql = <<-sql
      select distinct mock_id from comments where mock_id IS NOT NULL
      order by created_at DESC limit 5
    sql
    mock_ids = Comment.find_by_sql(sql).map(&:mock_id)
    mock_ids.map do |mock_id|
      mock = Mock.find(mock_id)
      [mock, mock.most_recent_comment]
    end
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
