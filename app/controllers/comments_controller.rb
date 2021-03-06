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
      @feeling = Award.maybe_grant_award(@comment)
      if @feeling
        redirect_to mock_path(:id => @comment.mock, :feeling => @feeling)
      else
        redirect_to mock_path(@comment.mock)
      end
    rescue ActiveRecord::RecordInvalid => bang
      flash[:notice] = bang.message
      @mock = @comment.mock
      render :template => "/mocks/show"
      return
    end
  end

  def ajax_create
    @comment = Comment.new(params[:comment])
    @comment.save!
    @mock = @comment.mock
    log_view
    render :partial => "/mocks/child_comment",
           :locals => {:comment => @comment.parent, :child => @comment}
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to mock_path(comment.mock)
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
