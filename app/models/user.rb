class User < ActiveRecord::Base
  def first_name
    name.split.first
  end
end
