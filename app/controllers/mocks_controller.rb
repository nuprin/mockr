class MocksController < ApplicationController
  def new
  end

  def create
    mock = Mock.new(params[:mock])
    if params[:project]
      if params[:project][:id].blank?
        project_id = Project.create_new_untitled_project!.id
      else
        project_id = params[:project][:id].to_i
      end
      mock.attach_mock_list_if_necessary!(project_id)
    end
    begin
      mock.save!
      redirect_to mock_path(mock)
    rescue ActiveRecord::RecordInvalid
      render :action => :new
    end
  end

  # TODO [chris]: Don't allow guest viewers to view this page.
  def show
    # path = params[:mock_path]
    # @mock = Mock.for(path)
    @mock = Mock.find(params[:id])
    @last_viewed_at = MockView.last_viewed_at(@mock, viewer) if viewer.real?
    @title = "#{@mock.dir} | #{@mock.title}"
    @sidebar = !cookies[:sidebar] || (cookies[:sidebar].first.to_i == 1)
    log_view
    render :layout => "/layouts/mocks/show"
  rescue Mock::MockPathIsDirectory => ex
    @mock = ex.mock
    redirect_to ex.mock ? mock_path(ex.mock) : '/'
  rescue Mock::MockDoesNotExist => boom
    redirect_to home_url
  end

  def index
    @mocks = Mock.recent.all
    respond_to do |format|
      format.atom
    end
  end

  def edit
    @mock = Mock.find(params[:id])
  end
  
  def update
    @mock = Mock.find(params[:id])
    @mock.update_attributes(params[:mock])
    Notifier.deliver_new_mock(@mock)
    redirect_to mock_path(@mock)
  end
end
