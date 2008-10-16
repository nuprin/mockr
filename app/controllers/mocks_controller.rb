class MocksController < ApplicationController

  # TODO: accept params[:filter], which can be "happy," "sad," or the id of 
  # an author.
  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @title = path.split('/').last(2).join(' / ')
    @comments = @mock.comments
  rescue Mock::MockPathIsDirectory => ex
    redirect_to url_for(ex.mock)
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
