class MocksController < ApplicationController

  def show
    @mock = Mock.for(params[:mock_path])
    @comments = Comment.stubbed_comments
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
