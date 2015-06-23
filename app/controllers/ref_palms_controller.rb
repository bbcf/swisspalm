class RefPalmsController < ApplicationController
  # GET /ref_palms
  # GET /ref_palms.json
  def index
    @ref_palms = RefPalm.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ref_palms }
    end
  end

  # GET /ref_palms/1
  # GET /ref_palms/1.json
  def show
    @ref_palm = RefPalm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ref_palm }
    end
  end

  # GET /ref_palms/new
  # GET /ref_palms/new.json
  def new
    @ref_palm = RefPalm.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ref_palm }
    end
  end

  # GET /ref_palms/1/edit
  def edit
    @ref_palm = RefPalm.find(params[:id])
  end

  # POST /ref_palms
  # POST /ref_palms.json
  def create
    @ref_palm = RefPalm.new(params[:ref_palm])

    respond_to do |format|
      if @ref_palm.save
        format.html { redirect_to @ref_palm, notice: 'Ref palm was successfully created.' }
        format.json { render json: @ref_palm, status: :created, location: @ref_palm }
      else
        format.html { render action: "new" }
        format.json { render json: @ref_palm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ref_palms/1
  # PUT /ref_palms/1.json
  def update
    @ref_palm = RefPalm.find(params[:id])

    respond_to do |format|
      if @ref_palm.update_attributes(params[:ref_palm])
        format.html { redirect_to @ref_palm, notice: 'Ref palm was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ref_palm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ref_palms/1
  # DELETE /ref_palms/1.json
  def destroy
    @ref_palm = RefPalm.find(params[:id])
    @ref_palm.destroy

    respond_to do |format|
      format.html { redirect_to ref_palms_url }
      format.json { head :no_content }
    end
  end
end
