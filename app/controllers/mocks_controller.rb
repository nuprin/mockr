class MocksController < ApplicationController

  def show
    @mock = Mock.for(params[:mock_path])
    @comments = @mock.comments
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
