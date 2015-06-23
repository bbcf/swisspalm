class HistorySitesController < ApplicationController
  # GET /history_sites
  # GET /history_sites.json
  def index
    @history_sites = HistorySite.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @history_sites }
    end
  end

  # GET /history_sites/1
  # GET /history_sites/1.json
  def show
    @history_site = HistorySite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @history_site }
    end
  end

  # GET /history_sites/new
  # GET /history_sites/new.json
  def new
    @history_site = HistorySite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @history_site }
    end
  end

  # GET /history_sites/1/edit
  def edit
    @history_site = HistorySite.find(params[:id])
  end

  # POST /history_sites
  # POST /history_sites.json
  def create
    @history_site = HistorySite.new(params[:history_site])

    respond_to do |format|
      if @history_site.save
        format.html { redirect_to @history_site, notice: 'History site was successfully created.' }
        format.json { render json: @history_site, status: :created, location: @history_site }
      else
        format.html { render action: "new" }
        format.json { render json: @history_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /history_sites/1
  # PUT /history_sites/1.json
  def update
    @history_site = HistorySite.find(params[:id])

    respond_to do |format|
      if @history_site.update_attributes(params[:history_site])
        format.html { redirect_to @history_site, notice: 'History site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @history_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /history_sites/1
  # DELETE /history_sites/1.json
  def destroy
    @history_site = HistorySite.find(params[:id])
    @history_site.destroy

    respond_to do |format|
      format.html { redirect_to history_sites_url }
      format.json { head :no_content }
    end
  end
end
