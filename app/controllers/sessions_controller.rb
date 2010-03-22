class SessionsController < ApplicationController
  skip_before_filter :require_authentication

  def new; end
  
  def create
    if params[:session][:user_id].to_i == 0
      user_id = User.create!(params[:user]).id
    else
      user_id = params[:session][:user_id].to_i
    end
    session[:user_id] = user_id
    url = params[:session][:redirect_url] || home_url
    redirect_to url
  end
end
