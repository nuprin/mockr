class MockListsController < ApplicationController
  # GET /mock_lists
  # GET /mock_lists.xml
  def index
    @mock_lists = MockList.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mock_lists }
    end
  end

  # GET /mock_lists/1
  # GET /mock_lists/1.xml
  def show
    @mock_list = MockList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mock_list }
    end
  end

  # GET /mock_lists/new
  # GET /mock_lists/new.xml
  def new
    @mock_list = MockList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mock_list }
    end
  end

  # GET /mock_lists/1/edit
  def edit
    @mock_list = MockList.find(params[:id])
  end

  # POST /mock_lists
  # POST /mock_lists.xml
  def create
    @mock_list = MockList.new(params[:mock_list])

    respond_to do |format|
      if @mock_list.save
        flash[:notice] = 'MockList was successfully created.'
        format.html { redirect_to(@mock_list) }
        format.xml  { render :xml => @mock_list, :status => :created, :location => @mock_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mock_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mock_lists/1
  # PUT /mock_lists/1.xml
  def update
    @mock_list = MockList.find(params[:id])

    respond_to do |format|
      if @mock_list.update_attributes(params[:mock_list])
        flash[:notice] = 'MockList was successfully updated.'
        format.html { redirect_to(@mock_list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mock_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mock_lists/1
  # DELETE /mock_lists/1.xml
  def destroy
    @mock_list = MockList.find(params[:id])
    @mock_list.destroy

    respond_to do |format|
      format.html { redirect_to(mock_lists_url) }
      format.xml  { head :ok }
    end
  end
end
