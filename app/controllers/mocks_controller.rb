class MocksController < ApplicationController

  after_filter :log_view, :only => :show

  def show
    path = params[:mock_path]
    @mock = Mock.for(path)
    @title = "#{@mock.dir} | #{@mock.title}"
  rescue Mock::MockPathIsDirectory => ex
    logger.info ex.mock.inspect
    redirect_to ex.mock ? mock_url(ex.mock) : '/'
  rescue Mock::MockDoesNotExist => boom
    render :text => "Mock does not exist: #{boom.path}"
  end

  def log_view
    if viewer.real?
      MockView.log_view(@mock, viewer)
    end
  end
end
