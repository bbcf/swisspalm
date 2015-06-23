class OrthoSourcesController < ApplicationController
  # GET /ortho_sources
  # GET /ortho_sources.json
  def index
    @ortho_sources = OrthoSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ortho_sources }
    end
  end

  # GET /ortho_sources/1
  # GET /ortho_sources/1.json
  def show
    @ortho_source = OrthoSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ortho_source }
    end
  end

  # GET /ortho_sources/new
  # GET /ortho_sources/new.json
  def new
    @ortho_source = OrthoSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ortho_source }
    end
  end

  # GET /ortho_sources/1/edit
  def edit
    @ortho_source = OrthoSource.find(params[:id])
  end

  # POST /ortho_sources
  # POST /ortho_sources.json
  def create
    @ortho_source = OrthoSource.new(params[:ortho_source])

    respond_to do |format|
      if @ortho_source.save
        format.html { redirect_to @ortho_source, notice: 'Ortho source was successfully created.' }
        format.json { render json: @ortho_source, status: :created, location: @ortho_source }
      else
        format.html { render action: "new" }
        format.json { render json: @ortho_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ortho_sources/1
  # PUT /ortho_sources/1.json
  def update
    @ortho_source = OrthoSource.find(params[:id])

    respond_to do |format|
      if @ortho_source.update_attributes(params[:ortho_source])
        format.html { redirect_to @ortho_source, notice: 'Ortho source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ortho_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ortho_sources/1
  # DELETE /ortho_sources/1.json
  def destroy
    @ortho_source = OrthoSource.find(params[:id])
    @ortho_source.destroy

    respond_to do |format|
      format.html { redirect_to ortho_sources_url }
      format.json { head :no_content }
    end
  end
end
