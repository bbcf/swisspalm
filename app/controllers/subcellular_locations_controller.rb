class SubcellularLocationsController < ApplicationController
  # GET /subcellular_locations
  # GET /subcellular_locations.json
  def index
    @subcellular_locations = SubcellularLocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subcellular_locations }
    end
  end

  # GET /subcellular_locations/1
  # GET /subcellular_locations/1.json
  def show
    @subcellular_location = SubcellularLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subcellular_location }
    end
  end

  # GET /subcellular_locations/new
  # GET /subcellular_locations/new.json
  def new
    @subcellular_location = SubcellularLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subcellular_location }
    end
  end

  # GET /subcellular_locations/1/edit
  def edit
    @subcellular_location = SubcellularLocation.find(params[:id])
  end

  # POST /subcellular_locations
  # POST /subcellular_locations.json
  def create
    @subcellular_location = SubcellularLocation.new(params[:subcellular_location])

    respond_to do |format|
      if @subcellular_location.save
        format.html { redirect_to @subcellular_location, notice: 'Subcellular location was successfully created.' }
        format.json { render json: @subcellular_location, status: :created, location: @subcellular_location }
      else
        format.html { render action: "new" }
        format.json { render json: @subcellular_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subcellular_locations/1
  # PUT /subcellular_locations/1.json
  def update
    @subcellular_location = SubcellularLocation.find(params[:id])

    respond_to do |format|
      if @subcellular_location.update_attributes(params[:subcellular_location])
        format.html { redirect_to @subcellular_location, notice: 'Subcellular location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subcellular_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subcellular_locations/1
  # DELETE /subcellular_locations/1.json
  def destroy
    @subcellular_location = SubcellularLocation.find(params[:id])
    @subcellular_location.destroy

    respond_to do |format|
      format.html { redirect_to subcellular_locations_url }
      format.json { head :no_content }
    end
  end
end
