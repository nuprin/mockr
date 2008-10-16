class Mock < ActiveRecord::Base
  MOCK_PATH = "public/images/mocks"

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
    my_index = ordered_family.index(self)
    ordered_family[my_index+1]
  end

  def prev
    my_index = ordered_family.index(self)
    return nil if my_index == 0
    ordered_family[my_index-1]
  end

  def family_filenames
    @family_filenames ||=
      Dir.glob("#{MOCK_PATH}/#{dir}/*").select do |filename|
        filename.ends_with?('jpg') ||
        filename.ends_with?('png') ||
        filename.ends_with?('gif')
      end.map do |path|
        path.split('/')[3..-1].join('/')
      end
  end

  def <=>(other)
    self.revision <=> other.revision
  end

  def revision
    /\w+-(\d+)\.(jpg|gif|png)/ =~ filename ? $1.to_i : -1
  end

  def ordered_family
    @ordered_family ||= family_filenames.map do |sibling_path|
      Mock.for(sibling_path)
    end.sort
  end

  # TODO: Implement.
  def happy_count
    10
  end
  
  # TODO: Implement.
  def sad_count
    5
  end
end
