class UniprotStatusesController < ApplicationController
  # GET /uniprot_statuses
  # GET /uniprot_statuses.json
  def index
    @uniprot_statuses = UniprotStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uniprot_statuses }
    end
  end

  # GET /uniprot_statuses/1
  # GET /uniprot_statuses/1.json
  def show
    @uniprot_status = UniprotStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @uniprot_status }
    end
  end

  # GET /uniprot_statuses/new
  # GET /uniprot_statuses/new.json
  def new
    @uniprot_status = UniprotStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @uniprot_status }
    end
  end

  # GET /uniprot_statuses/1/edit
  def edit
    @uniprot_status = UniprotStatus.find(params[:id])
  end

  # POST /uniprot_statuses
  # POST /uniprot_statuses.json
  def create
    @uniprot_status = UniprotStatus.new(params[:uniprot_status])

    respond_to do |format|
      if @uniprot_status.save
        format.html { redirect_to @uniprot_status, notice: 'Uniprot status was successfully created.' }
        format.json { render json: @uniprot_status, status: :created, location: @uniprot_status }
      else
        format.html { render action: "new" }
        format.json { render json: @uniprot_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /uniprot_statuses/1
  # PUT /uniprot_statuses/1.json
  def update
    @uniprot_status = UniprotStatus.find(params[:id])

    respond_to do |format|
      if @uniprot_status.update_attributes(params[:uniprot_status])
        format.html { redirect_to @uniprot_status, notice: 'Uniprot status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @uniprot_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uniprot_statuses/1
  # DELETE /uniprot_statuses/1.json
  def destroy
    @uniprot_status = UniprotStatus.find(params[:id])
    @uniprot_status.destroy

    respond_to do |format|
      format.html { redirect_to uniprot_statuses_url }
      format.json { head :no_content }
    end
  end
end
