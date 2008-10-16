class CommentsController < ApplicationController

  def create
    if params[:comment][:author_id].to_i == 0
      params[:comment].delete(:author_id)
    end
    @comment = Comment.new(params[:comment])
    @mock = Mock.find(params[:comment][:mock_id])
    begin
      @comment.save!
      session[:user_id] = params[:comment][:author_id].to_i
      redirect_to mock_url(@mock)
    rescue ActiveRecord::RecordInvalid => bang
      flash[:notice] = bang.message
      render :template => "/mocks/show"
      return
    end
  end

end
