class SettingsController < ApplicationController
  def email
    @setting = Setting.find_or_create_by_key("notification_email")
  end
  
  def update
    setting = Setting.find_by_key(params[:setting][:key])
    setting.update_attributes(params[:setting])
    redirect_to :back
  end
end
