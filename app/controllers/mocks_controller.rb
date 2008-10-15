class MocksController < ApplicationController

  def show
    @mock = Mock.for(params[:mock_path])
    render :text => "Mock #{@mock.id}: #{@mock.path}"
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

private

end
