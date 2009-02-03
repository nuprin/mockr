class CommentsController < ApplicationController
  def create
    if params[:comment][:author_id].to_i == 0
      params[:comment].delete(:author_id)
    else
      set_viewer
    end
    forge_author_if_requested
    @comment = Comment.new(params[:comment])
    begin
      @comment.save!
      redirect_to mock_url(@comment.mock)
    rescue ActiveRecord::RecordInvalid => bang
      flash[:notice] = bang.message
      @mock = @comment.mock
      render :template => "/mocks/show"
      return
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to mock_url(comment.mock)
  end

  def forge_author_if_requested
    @md, @name, @actual_comment =
      *params[:comment][:text].match(/^(\w+\s?\w*):\s*(.*)/m)
    if @name && (@actual_author = User.with_first_name(@name).first)
      params[:comment][:author_id] = @actual_author.id
      params[:comment][:text] = @actual_comment
    end
  end

  def set_viewer
    session[:user_id] = params[:comment][:author_id].to_i
  end
end
