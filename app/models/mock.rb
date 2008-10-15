class Mock < ActiveRecord::Base
  class MockDoesNotExist < StandardError
    attr_reader :path
    def initialize(path)
      @path = path
    end
  end

  def self.for(path)
    unless File.exist?("public/images/mocks/#{path}")
      raise MockDoesNotExist.new(path)
    end
    Mock.find_by_path(path) || Mock.create(:path => path)
  end

  def image_path
    "mocks/#{path}"
  end
  
  # TODO[chris]: The name of a mock is the capitalized filename without the 
  # extension and dash.
  def name
    "Petitions 5"
  end
end
