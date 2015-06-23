class OrthodbBestOrthologuesController < ApplicationController
  # GET /orthodb_best_orthologues
  # GET /orthodb_best_orthologues.json
  def index
    @orthodb_best_orthologues = OrthodbBestOrthologue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orthodb_best_orthologues }
    end
  end

  # GET /orthodb_best_orthologues/1
  # GET /orthodb_best_orthologues/1.json
  def show
    @orthodb_best_orthologue = OrthodbBestOrthologue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @orthodb_best_orthologue }
    end
  end

  # GET /orthodb_best_orthologues/new
  # GET /orthodb_best_orthologues/new.json
  def new
    @orthodb_best_orthologue = OrthodbBestOrthologue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @orthodb_best_orthologue }
    end
  end

  # GET /orthodb_best_orthologues/1/edit
  def edit
    @orthodb_best_orthologue = OrthodbBestOrthologue.find(params[:id])
  end

  # POST /orthodb_best_orthologues
  # POST /orthodb_best_orthologues.json
  def create
    @orthodb_best_orthologue = OrthodbBestOrthologue.new(params[:orthodb_best_orthologue])

    respond_to do |format|
      if @orthodb_best_orthologue.save
        format.html { redirect_to @orthodb_best_orthologue, notice: 'Orthodb best orthologue was successfully created.' }
        format.json { render json: @orthodb_best_orthologue, status: :created, location: @orthodb_best_orthologue }
      else
        format.html { render action: "new" }
        format.json { render json: @orthodb_best_orthologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orthodb_best_orthologues/1
  # PUT /orthodb_best_orthologues/1.json
  def update
    @orthodb_best_orthologue = OrthodbBestOrthologue.find(params[:id])

    respond_to do |format|
      if @orthodb_best_orthologue.update_attributes(params[:orthodb_best_orthologue])
        format.html { redirect_to @orthodb_best_orthologue, notice: 'Orthodb best orthologue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @orthodb_best_orthologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orthodb_best_orthologues/1
  # DELETE /orthodb_best_orthologues/1.json
  def destroy
    @orthodb_best_orthologue = OrthodbBestOrthologue.find(params[:id])
    @orthodb_best_orthologue.destroy

    respond_to do |format|
      format.html { redirect_to orthodb_best_orthologues_url }
      format.json { head :no_content }
    end
  end
end
