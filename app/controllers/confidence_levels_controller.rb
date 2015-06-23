class ConfidenceLevelsController < ApplicationController
  # GET /confidence_levels
  # GET /confidence_levels.json
  def index
    @confidence_levels = ConfidenceLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @confidence_levels }
    end
  end

  # GET /confidence_levels/1
  # GET /confidence_levels/1.json
  def show
    @confidence_level = ConfidenceLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @confidence_level }
    end
  end

  # GET /confidence_levels/new
  # GET /confidence_levels/new.json
  def new
    @confidence_level = ConfidenceLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @confidence_level }
    end
  end

  # GET /confidence_levels/1/edit
  def edit
    @confidence_level = ConfidenceLevel.find(params[:id])
  end

  # POST /confidence_levels
  # POST /confidence_levels.json
  def create
    @confidence_level = ConfidenceLevel.new(params[:confidence_level])

    respond_to do |format|
      if @confidence_level.save
        format.html { redirect_to @confidence_level, notice: 'Confidence level was successfully created.' }
        format.json { render json: @confidence_level, status: :created, location: @confidence_level }
      else
        format.html { render action: "new" }
        format.json { render json: @confidence_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /confidence_levels/1
  # PUT /confidence_levels/1.json
  def update
    @confidence_level = ConfidenceLevel.find(params[:id])

    respond_to do |format|
      if @confidence_level.update_attributes(params[:confidence_level])
        format.html { redirect_to @confidence_level, notice: 'Confidence level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @confidence_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /confidence_levels/1
  # DELETE /confidence_levels/1.json
  def destroy
    @confidence_level = ConfidenceLevel.find(params[:id])
    @confidence_level.destroy

    respond_to do |format|
      format.html { redirect_to confidence_levels_url }
      format.json { head :no_content }
    end
  end
end
