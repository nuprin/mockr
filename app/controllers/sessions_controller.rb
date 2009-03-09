class SessionsController < ApplicationController
  layout "home"

  skip_before_filter :require_authentication

  def new; end
  
  def create
    session[:user_id] = params[:session][:user_id].to_i
    url = params[:session][:redirect_url] || "/"
    redirect_to url
  end
end
