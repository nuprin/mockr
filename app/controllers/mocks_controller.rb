class MocksController < ApplicationController

  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @title = path.split('/').last(2).join(' / ')
    @comments = @mock.filtered_comments(params[:feedback_filter])
  rescue Mock::MockPathIsDirectory => ex
    redirect_to ex.mock ? mock_url(ex.mock) : '/'
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
