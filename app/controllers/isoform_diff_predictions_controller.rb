class IsoformDiffPredictionsController < ApplicationController
  # GET /isoform_diff_predictions
  # GET /isoform_diff_predictions.json
  def index
    @isoform_diff_predictions = IsoformDiffPrediction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @isoform_diff_predictions }
    end
  end

  # GET /isoform_diff_predictions/1
  # GET /isoform_diff_predictions/1.json
  def show
    @isoform_diff_prediction = IsoformDiffPrediction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @isoform_diff_prediction }
    end
  end

  # GET /isoform_diff_predictions/new
  # GET /isoform_diff_predictions/new.json
  def new
    @isoform_diff_prediction = IsoformDiffPrediction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @isoform_diff_prediction }
    end
  end

  # GET /isoform_diff_predictions/1/edit
  def edit
    @isoform_diff_prediction = IsoformDiffPrediction.find(params[:id])
  end

  # POST /isoform_diff_predictions
  # POST /isoform_diff_predictions.json
  def create
    @isoform_diff_prediction = IsoformDiffPrediction.new(params[:isoform_diff_prediction])

    respond_to do |format|
      if @isoform_diff_prediction.save
        format.html { redirect_to @isoform_diff_prediction, notice: 'Isoform diff prediction was successfully created.' }
        format.json { render json: @isoform_diff_prediction, status: :created, location: @isoform_diff_prediction }
      else
        format.html { render action: "new" }
        format.json { render json: @isoform_diff_prediction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /isoform_diff_predictions/1
  # PUT /isoform_diff_predictions/1.json
  def update
    @isoform_diff_prediction = IsoformDiffPrediction.find(params[:id])

    respond_to do |format|
      if @isoform_diff_prediction.update_attributes(params[:isoform_diff_prediction])
        format.html { redirect_to @isoform_diff_prediction, notice: 'Isoform diff prediction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @isoform_diff_prediction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /isoform_diff_predictions/1
  # DELETE /isoform_diff_predictions/1.json
  def destroy
    @isoform_diff_prediction = IsoformDiffPrediction.find(params[:id])
    @isoform_diff_prediction.destroy

    respond_to do |format|
      format.html { redirect_to isoform_diff_predictions_url }
      format.json { head :no_content }
    end
  end
end
