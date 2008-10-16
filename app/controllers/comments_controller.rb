class CommentsController < ApplicationController

  def create
    begin
      Comment.create!(params[:comment])
    rescue ActiveRecord::RecordInvalid => bang
      flash[:notice] = "Please include a comment and a feeling."
    end
    redirect_to :back
  end

end
