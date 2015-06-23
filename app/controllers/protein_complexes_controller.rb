class ProteinComplexesController < ApplicationController
  # GET /protein_complexes
  # GET /protein_complexes.json
  def index
    @protein_complexes = ProteinComplex.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @protein_complexes }
    end
  end

  # GET /protein_complexes/1
  # GET /protein_complexes/1.json
  def show
    @protein_complex = ProteinComplex.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protein_complex }
    end
  end

  # GET /protein_complexes/new
  # GET /protein_complexes/new.json
  def new
    @protein_complex = ProteinComplex.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protein_complex }
    end
  end

  # GET /protein_complexes/1/edit
  def edit
    @protein_complex = ProteinComplex.find(params[:id])
  end

  # POST /protein_complexes
  # POST /protein_complexes.json
  def create
    @protein_complex = ProteinComplex.new(params[:protein_complex])

    respond_to do |format|
      if @protein_complex.save
        format.html { redirect_to @protein_complex, notice: 'Protein complex was successfully created.' }
        format.json { render json: @protein_complex, status: :created, location: @protein_complex }
      else
        format.html { render action: "new" }
        format.json { render json: @protein_complex.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /protein_complexes/1
  # PUT /protein_complexes/1.json
  def update
    @protein_complex = ProteinComplex.find(params[:id])

    respond_to do |format|
      if @protein_complex.update_attributes(params[:protein_complex])
        format.html { redirect_to @protein_complex, notice: 'Protein complex was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @protein_complex.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protein_complexes/1
  # DELETE /protein_complexes/1.json
  def destroy
    @protein_complex = ProteinComplex.find(params[:id])
    @protein_complex.destroy

    respond_to do |format|
      format.html { redirect_to protein_complexes_url }
      format.json { head :no_content }
    end
  end
end
