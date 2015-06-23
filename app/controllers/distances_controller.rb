class DistancesController < ApplicationController
  # GET /distances
  # GET /distances.json
  def index
    @distances = Distance.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @distances }
    end
  end

  # GET /distances/1
  # GET /distances/1.json
  def show
    @distance = Distance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @distance }
    end
  end

  # GET /distances/new
  # GET /distances/new.json
  def new
    @distance = Distance.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @distance }
    end
  end

  # GET /distances/1/edit
  def edit
    @distance = Distance.find(params[:id])
  end

  # POST /distances
  # POST /distances.json
  def create
    @distance = Distance.new(params[:distance])

    respond_to do |format|
      if @distance.save
        format.html { redirect_to @distance, notice: 'Distance was successfully created.' }
        format.json { render json: @distance, status: :created, location: @distance }
      else
        format.html { render action: "new" }
        format.json { render json: @distance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /distances/1
  # PUT /distances/1.json
  def update
    @distance = Distance.find(params[:id])

    respond_to do |format|
      if @distance.update_attributes(params[:distance])
        format.html { redirect_to @distance, notice: 'Distance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @distance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /distances/1
  # DELETE /distances/1.json
  def destroy
    @distance = Distance.find(params[:id])
    @distance.destroy

    respond_to do |format|
      format.html { redirect_to distances_url }
      format.json { head :no_content }
    end
  end
end
