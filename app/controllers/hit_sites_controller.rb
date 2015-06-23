class HitSitesController < ApplicationController
  # GET /hit_sites
  # GET /hit_sites.json
  def index
    @hit_sites = HitSite.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hit_sites }
    end
  end

  # GET /hit_sites/1
  # GET /hit_sites/1.json
  def show
    @hit_site = HitSite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hit_site }
    end
  end

  # GET /hit_sites/new
  # GET /hit_sites/new.json
  def new
    @hit_site = HitSite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hit_site }
    end
  end

  # GET /hit_sites/1/edit
  def edit
    @hit_site = HitSite.find(params[:id])
  end

  # POST /hit_sites
  # POST /hit_sites.json
  def create
    @hit_site = HitSite.new(params[:hit_site])

    respond_to do |format|
      if @hit_site.save
        format.html { redirect_to @hit_site, notice: 'Hit site was successfully created.' }
        format.json { render json: @hit_site, status: :created, location: @hit_site }
      else
        format.html { render action: "new" }
        format.json { render json: @hit_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hit_sites/1
  # PUT /hit_sites/1.json
  def update
    @hit_site = HitSite.find(params[:id])

    respond_to do |format|
      if @hit_site.update_attributes(params[:hit_site])
        format.html { redirect_to @hit_site, notice: 'Hit site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hit_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hit_sites/1
  # DELETE /hit_sites/1.json
  def destroy
    @hit_site = HitSite.find(params[:id])
    @hit_site.destroy

    respond_to do |format|
      format.html { redirect_to hit_sites_url }
      format.json { head :no_content }
    end
  end
end
