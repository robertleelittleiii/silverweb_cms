class RightsController < ApplicationController

  def index
   @rights = Right.find(:all, :order => :name)

  respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rights }
  end
end
  def edit
    @right = Right.find(params[:id])

      respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
      end
  end

  def new
    @right = Right.new

     respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
     end
  end

  def show
        @right = Right.find(params[:id])

      respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @right }
       end
  end

  def create
    @right = Right.new(params[:right])

    respond_to do |format|
      if @right.save
        flash[:notice] = "Right #{@right.name} was successfully created."
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @right, :status => :created,
                             :location => @right }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @right.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  def update
    @right = Right.find(params[:id])

    respond_to do |format|
      if @right.update_attributes(params[:right])
        flash[:notice] = "Right #{@right.name} was successfully updated."
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @right.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

 def destroy
  @right = Right.find(params[:id])
  begin
    @right.destroy
      flash[:notice] = "Right #{right.name} deleted"
  rescue Exception => e
    flash[:notice] = e.message
  end
  respond_to do |format|
    format.html { redirect_to(rights_url) }
    format.xml { head :ok }
  end

end



end
