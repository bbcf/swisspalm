class PredictionsController < ApplicationController
  # GET /predictions
  # GET /predictions.json
  def index
#    @predictions = Prediction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @predictions }
    end
  end

  # GET /predictions/1
  # GET /predictions/1.json
  def show
    @prediction = Prediction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @prediction }
    end
  end

  # GET /predictions/new
  # GET /predictions/new.json
  def new
    @prediction = Prediction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @prediction }
    end
  end

  # GET /predictions/1/edit
  def edit
    @prediction = Prediction.find(params[:id])
  end

  # POST /predictions
  # POST /predictions.json
  def create
    @prediction = Prediction.new(params[:prediction])

    respond_to do |format|
      if @prediction.save
        format.html { redirect_to @prediction, notice: 'Prediction was successfully created.' }
        format.json { render json: @prediction, status: :created, location: @prediction }
      else
        format.html { render action: "new" }
        format.json { render json: @prediction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /predictions/1
  # PUT /predictions/1.json
  def update
    @prediction = Prediction.find(params[:id])

    respond_to do |format|
      if @prediction.update_attributes(params[:prediction])
        format.html { redirect_to @prediction, notice: 'Prediction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @prediction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /predictions/1
  # DELETE /predictions/1.json
  def destroy
    @prediction = Prediction.find(params[:id])
    @prediction.destroy

    respond_to do |format|
      format.html { redirect_to predictions_url }
      format.json { head :no_content }
    end
  end
end
