class Feeling < ActiveRecord::Base
  FEELING_NAMES = self.find(:all).map(&:name)
  def self.method_missing(method, *args)
    if FEELING_NAMES.include? method.to_s
      return Feeling.find_by_name(method.to_s)
    end
    super(method, *args)
  end
end
