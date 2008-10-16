class User < ActiveRecord::Base
  def first_name
    name.split.first
  end

  def real?
    !self.id.nil?
  end
end
