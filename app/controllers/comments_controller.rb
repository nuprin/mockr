class CommentsController < ApplicationController

  def create
    params[:comment].delete(:author_id) if params[:comment][:author_id].to_i == 0
    begin
      Comment.create!(params[:comment])
    rescue ActiveRecord::RecordInvalid => bang
      flash[:notice] = bang.message
    end
    redirect_to :back
  end

end
