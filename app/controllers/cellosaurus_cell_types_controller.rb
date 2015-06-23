class CellosaurusCellTypesController < ApplicationController
  # GET /cellosaurus_cell_types
  # GET /cellosaurus_cell_types.json
  def index
    @cellosaurus_cell_types = CellosaurusCellType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cellosaurus_cell_types }
    end
  end

  # GET /cellosaurus_cell_types/1
  # GET /cellosaurus_cell_types/1.json
  def show
    @cellosaurus_cell_type = CellosaurusCellType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cellosaurus_cell_type }
    end
  end

  # GET /cellosaurus_cell_types/new
  # GET /cellosaurus_cell_types/new.json
  def new
    @cellosaurus_cell_type = CellosaurusCellType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cellosaurus_cell_type }
    end
  end

  # GET /cellosaurus_cell_types/1/edit
  def edit
    @cellosaurus_cell_type = CellosaurusCellType.find(params[:id])
  end

  # POST /cellosaurus_cell_types
  # POST /cellosaurus_cell_types.json
  def create
    @cellosaurus_cell_type = CellosaurusCellType.new(params[:cellosaurus_cell_type])

    respond_to do |format|
      if @cellosaurus_cell_type.save
        format.html { redirect_to @cellosaurus_cell_type, notice: 'Cellosaurus cell type was successfully created.' }
        format.json { render json: @cellosaurus_cell_type, status: :created, location: @cellosaurus_cell_type }
      else
        format.html { render action: "new" }
        format.json { render json: @cellosaurus_cell_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cellosaurus_cell_types/1
  # PUT /cellosaurus_cell_types/1.json
  def update
    @cellosaurus_cell_type = CellosaurusCellType.find(params[:id])

    respond_to do |format|
      if @cellosaurus_cell_type.update_attributes(params[:cellosaurus_cell_type])
        format.html { redirect_to @cellosaurus_cell_type, notice: 'Cellosaurus cell type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cellosaurus_cell_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cellosaurus_cell_types/1
  # DELETE /cellosaurus_cell_types/1.json
  def destroy
    @cellosaurus_cell_type = CellosaurusCellType.find(params[:id])
    @cellosaurus_cell_type.destroy

    respond_to do |format|
      format.html { redirect_to cellosaurus_cell_types_url }
      format.json { head :no_content }
    end
  end
end
