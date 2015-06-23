class GeneNamesController < ApplicationController
  # GET /gene_names
  # GET /gene_names.json
  def index
    @gene_names = GeneName.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gene_names }
    end
  end

  # GET /gene_names/1
  # GET /gene_names/1.json
  def show
    @gene_name = GeneName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gene_name }
    end
  end

  # GET /gene_names/new
  # GET /gene_names/new.json
  def new
    @gene_name = GeneName.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gene_name }
    end
  end

  # GET /gene_names/1/edit
  def edit
    @gene_name = GeneName.find(params[:id])
  end

  # POST /gene_names
  # POST /gene_names.json
  def create
    @gene_name = GeneName.new(params[:gene_name])

    respond_to do |format|
      if @gene_name.save
        format.html { redirect_to @gene_name, notice: 'Gene name was successfully created.' }
        format.json { render json: @gene_name, status: :created, location: @gene_name }
      else
        format.html { render action: "new" }
        format.json { render json: @gene_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gene_names/1
  # PUT /gene_names/1.json
  def update
    @gene_name = GeneName.find(params[:id])

    respond_to do |format|
      if @gene_name.update_attributes(params[:gene_name])
        format.html { redirect_to @gene_name, notice: 'Gene name was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gene_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gene_names/1
  # DELETE /gene_names/1.json
  def destroy
    @gene_name = GeneName.find(params[:id])
    @gene_name.destroy

    respond_to do |format|
      format.html { redirect_to gene_names_url }
      format.json { head :no_content }
    end
  end
end
