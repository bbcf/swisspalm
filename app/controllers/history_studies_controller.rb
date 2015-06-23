class HistoryStudiesController < ApplicationController
  # GET /history_studies
  # GET /history_studies.json
  def index
    @history_studies = HistoryStudy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @history_studies }
    end
  end

  # GET /history_studies/1
  # GET /history_studies/1.json
  def show
    @history_study = HistoryStudy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @history_study }
    end
  end

  # GET /history_studies/new
  # GET /history_studies/new.json
  def new
    @history_study = HistoryStudy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @history_study }
    end
  end

  # GET /history_studies/1/edit
  def edit
    @history_study = HistoryStudy.find(params[:id])
  end

  # POST /history_studies
  # POST /history_studies.json
  def create
    @history_study = HistoryStudy.new(params[:history_study])

    respond_to do |format|
      if @history_study.save
        format.html { redirect_to @history_study, notice: 'History study was successfully created.' }
        format.json { render json: @history_study, status: :created, location: @history_study }
      else
        format.html { render action: "new" }
        format.json { render json: @history_study.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /history_studies/1
  # PUT /history_studies/1.json
  def update
    @history_study = HistoryStudy.find(params[:id])

    respond_to do |format|
      if @history_study.update_attributes(params[:history_study])
        format.html { redirect_to @history_study, notice: 'History study was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @history_study.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /history_studies/1
  # DELETE /history_studies/1.json
  def destroy
    @history_study = HistoryStudy.find(params[:id])
    @history_study.destroy

    respond_to do |format|
      format.html { redirect_to history_studies_url }
      format.json { head :no_content }
    end
  end
end
