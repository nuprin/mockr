class MocksController < ApplicationController

  after_filter :log_view, :only => :show

  # TODO [chris]: Don't allow guest viewers to view this page.
  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @last_viewed_at = MockView.last_viewed_at(@mock, viewer) if viewer.real?
    @title = "#{@mock.dir} | #{@mock.title}"
    @sidebar = !cookies[:sidebar] || (cookies[:sidebar].first.to_i == 1)
  rescue Mock::MockPathIsDirectory => ex
    @mock = ex.mock
    redirect_to ex.mock ? mock_url(ex.mock) : '/'
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

  def edit
    @mock = Mock.find(params[:id])
  end
  
  def update
    @mock = Mock.find(params[:id])
    @mock.update_attributes(params[:mock])
    Notifier.deliver_new_mock(@mock)
    redirect_to mock_url(@mock)
  end
end
