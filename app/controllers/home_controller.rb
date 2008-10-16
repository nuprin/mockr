class HomeController < ApplicationController

  layout "home"

  def index
    @title = "Home"
  end

end
