# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :require_authentication
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c0343548cd9ee7aee309727618e8b6ca'

  def viewer
    @viewer = User.find_by_id(session[:user_id]) || User.new
  end
  helper_method :viewer

  def log_view
    if viewer.real? && @mock
      MockView.log_view(@mock, viewer)
    end
  end
  
  def require_authentication
    unless viewer.real?
      redirect_to new_session_path(:redirect_url => request.path)
    end
  end
end
