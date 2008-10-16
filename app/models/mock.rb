class Mock < ActiveRecord::Base

  MOCK_PATH = "public/images/mocks"

  has_many :comments

  class MockDoesNotExist < StandardError
    attr_reader :path
    def initialize(path)
      @path = path
    end
    def to_s
      @path
    end
  end

  def self.for(path)
    full_path = "#{MOCK_PATH}/#{path}"
    unless File.exist?(full_path)
      raise MockDoesNotExist.new(full_path)
    end

    return Mock.last_mock_for(path) if File.directory?(full_path)

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
    ordered_feature[my_index+1]
  end

  def prev
    my_index = ordered_feature.index(self)
    return nil if my_index == 0
    ordered_feature[my_index-1]
  end

  def <=>(other)
    self.revision <=> other.revision
  end

  def revision
    /\w+-(\d+)\.(jpg|gif|png)/ =~ filename ? $1.to_i : -1
  end

  def self.feature_filenames(feature)
    @feature_filenames ||=
      Dir.glob("#{MOCK_PATH}/#{feature}/*").select do |filename|
        filename.ends_with?('jpg') ||
        filename.ends_with?('png') ||
        filename.ends_with?('gif')
      end.map do |path|
        path.split('/')[3..-1].join('/')
      end
  end

  def self.ordered_feature(feature)
    @ordered_feature ||= feature_filenames(feature).map do |sibling_path|
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
end
