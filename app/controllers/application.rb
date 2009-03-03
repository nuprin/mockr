# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c0343548cd9ee7aee309727618e8b6ca'

  def mock_url(mock, query_string = "")
    "/#{mock.path}#{query_string}"
  end
  helper_method :mock_url

  def viewer
    @viewer = User.find_by_id(session[:user_id]) || User.new
  end
  helper_method :viewer

  def log_view
    if viewer.real? && @mock
      MockView.log_view(@mock, viewer)
    end
  end
end
