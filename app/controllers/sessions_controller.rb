class SessionsController < ApplicationController
  layout "home"
  def new; end
  
  def create
    session[:user_id] = params[:session][:user_id].to_i
    url = params[:session][:redirect_url] || "/"
    redirect_to url
  end
end
