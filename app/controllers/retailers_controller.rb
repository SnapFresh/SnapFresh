class RetailersController < ApplicationController
  # GET /retailers
  # GET /retailers.xml
  def index
    @retailers = Retailer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retailers }
    end
  end

  # GET /retailers/near/*query
  def near
    @origin = [params[:query][0],params[:query][1]]
    @retailers = Retailer.find :all,
                              :origin => @origin,
                              #:within => 5,
                              :order => 'distance',
                              :limit => 5
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  # GET /retailers/1
  # GET /retailers/1.xml
  def show
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  # GET /retailers/new
  # GET /retailers/new.xml
  def new
    @retailer = Retailer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retailer }
    end
  end

  # GET /retailers/1/edit
  def edit
    @retailer = Retailer.find(params[:id])
  end

  # POST /retailers
  # POST /retailers.xml
  def create
    @retailer = Retailer.new(params[:retailer])

    respond_to do |format|
      if @retailer.save
        format.html { redirect_to(@retailer, :notice => 'Retailer was successfully created.') }
        format.xml  { render :xml => @retailer, :status => :created, :location => @retailer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retailer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retailers/1
  # PUT /retailers/1.xml
  def update
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      if @retailer.update_attributes(params[:retailer])
        format.html { redirect_to(@retailer, :notice => 'Retailer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retailer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retailers/1
  # DELETE /retailers/1.xml
  def destroy
    @retailer = Retailer.find(params[:id])
    @retailer.destroy

    respond_to do |format|
      format.html { redirect_to(retailers_url) }
      format.xml  { head :ok }
    end
  end
end
