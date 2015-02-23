class UserAttributesController < ApplicationController
  # GET /user_attributes
  # GET /user_attributes.json
  def index
    @user_attributes = UserAttribute.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @user_attributes }
    end
  end

  # GET /user_attributes/1
  # GET /user_attributes/1.json
  def show
    @user_attribute = UserAttribute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @user_attribute }
    end
  end

  # GET /user_attributes/new
  # GET /user_attributes/new.json
  def new
    @user_attribute = UserAttribute.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @user_attribute }
    end
  end

  # GET /user_attributes/1/edit
  def edit
    @user_attribute = UserAttribute.find(params[:id])
  end

  # POST /user_attributes
  # POST /user_attributes.json
  def create
    @user_attribute = UserAttribute.new(params[:user_attribute])

    respond_to do |format|
      if @user_attribute.save
        format.html { redirect_to(@user_attribute, :notice => 'User attribute was successfully created.') }
        format.json  { render :json => @user_attribute, :status => :created, :location => @user_attribute }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @user_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_attributes/1
  # PUT /user_attributes/1.json
  def update
    @user_attribute = UserAttribute.find(params[:id])

    respond_to do |format|
      if @user_attribute.update_attributes(params[:user_attribute])
        format.html { redirect_to(@user_attribute, :notice => 'User attribute was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @user_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # DELETE /user_attributes/1
  # DELETE /user_attributes/1.json
  def destroy
    @user_attribute = UserAttribute.find(params[:id])
    @user_attribute.destroy

    respond_to do |format|
      format.html { redirect_to(user_attributes_url) }
      format.json  { head :ok }
    end
  end
end
