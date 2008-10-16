class CommentsController < ApplicationController

  def create
    comment = Comment.create!(params[:comment])
    redirect_to mock_url(comment.mock)
  end

end
