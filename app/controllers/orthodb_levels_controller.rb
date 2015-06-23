class OrthodbLevelsController < ApplicationController
  # GET /orthodb_levels
  # GET /orthodb_levels.json
  def index
    @orthodb_levels = OrthodbLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orthodb_levels }
    end
  end

  # GET /orthodb_levels/1
  # GET /orthodb_levels/1.json
  def show
    @orthodb_level = OrthodbLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @orthodb_level }
    end
  end

  # GET /orthodb_levels/new
  # GET /orthodb_levels/new.json
  def new
    @orthodb_level = OrthodbLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @orthodb_level }
    end
  end

  # GET /orthodb_levels/1/edit
  def edit
    @orthodb_level = OrthodbLevel.find(params[:id])
  end

  # POST /orthodb_levels
  # POST /orthodb_levels.json
  def create
    @orthodb_level = OrthodbLevel.new(params[:orthodb_level])

    respond_to do |format|
      if @orthodb_level.save
        format.html { redirect_to @orthodb_level, notice: 'Orthodb level was successfully created.' }
        format.json { render json: @orthodb_level, status: :created, location: @orthodb_level }
      else
        format.html { render action: "new" }
        format.json { render json: @orthodb_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orthodb_levels/1
  # PUT /orthodb_levels/1.json
  def update
    @orthodb_level = OrthodbLevel.find(params[:id])

    respond_to do |format|
      if @orthodb_level.update_attributes(params[:orthodb_level])
        format.html { redirect_to @orthodb_level, notice: 'Orthodb level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @orthodb_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orthodb_levels/1
  # DELETE /orthodb_levels/1.json
  def destroy
    @orthodb_level = OrthodbLevel.find(params[:id])
    @orthodb_level.destroy

    respond_to do |format|
      format.html { redirect_to orthodb_levels_url }
      format.json { head :no_content }
    end
  end
end
