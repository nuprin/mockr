class MocksController < ApplicationController

  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @title = path.split('/').last(2).join(' / ')
    @comments = @mock.comments
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
