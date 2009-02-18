class MocksController < ApplicationController

  after_filter :log_view, :only => :show

  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @title = "#{@mock.dir} | #{@mock.title}"
    @sidebar = !cookies[:sidebar] || (cookies[:sidebar].first.to_i == 1)
  rescue Mock::MockPathIsDirectory => ex
    @mock = ex.mock
    redirect_to ex.mock ? mock_url(ex.mock) : '/'
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

end
