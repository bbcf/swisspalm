class RefProteinsController < ApplicationController
  # GET /ref_proteins
  # GET /ref_proteins.json
  def index
    @ref_proteins = RefProtein.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ref_proteins }
    end
  end

  # GET /ref_proteins/1
  # GET /ref_proteins/1.json
  def show
    @ref_protein = RefProtein.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ref_protein }
    end
  end

  # GET /ref_proteins/new
  # GET /ref_proteins/new.json
  def new
    @ref_protein = RefProtein.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ref_protein }
    end
  end

  # GET /ref_proteins/1/edit
  def edit
    @ref_protein = RefProtein.find(params[:id])
  end

  # POST /ref_proteins
  # POST /ref_proteins.json
  def create
    @ref_protein = RefProtein.new(params[:ref_protein])

    respond_to do |format|
      if @ref_protein.save
        format.html { redirect_to @ref_protein, notice: 'Ref protein was successfully created.' }
        format.json { render json: @ref_protein, status: :created, location: @ref_protein }
      else
        format.html { render action: "new" }
        format.json { render json: @ref_protein.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ref_proteins/1
  # PUT /ref_proteins/1.json
  def update
    @ref_protein = RefProtein.find(params[:id])

    respond_to do |format|
      if @ref_protein.update_attributes(params[:ref_protein])
        format.html { redirect_to @ref_protein, notice: 'Ref protein was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ref_protein.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ref_proteins/1
  # DELETE /ref_proteins/1.json
  def destroy
    @ref_protein = RefProtein.find(params[:id])
    @ref_protein.destroy

    respond_to do |format|
      format.html { redirect_to ref_proteins_url }
      format.json { head :no_content }
    end
  end
end
