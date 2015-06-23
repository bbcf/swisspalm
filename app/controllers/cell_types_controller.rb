class CellTypesController < ApplicationController

before_filter :authorize

  # GET /cell_types
  # GET /cell_types.json
  def index
    @cell_types = CellType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cell_types }
    end
  end

  # GET /cell_types/1
  # GET /cell_types/1.json
  def show
    @cell_type = CellType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cell_type }
    end
  end

  # GET /cell_types/new
  # GET /cell_types/new.json
  def new
    @cell_type = CellType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cell_type }
    end
  end

  # GET /cell_types/1/edit
  def edit
    @cell_type = CellType.find(params[:id])
  end

  # POST /cell_types
  # POST /cell_types.json
  def create
    @cell_type = CellType.new(params[:cell_type])

    respond_to do |format|
      if @cell_type.save
        format.html { redirect_to @cell_type, notice: 'Cell type was successfully created.' }
        format.json { render json: @cell_type, status: :created, location: @cell_type }
      else
        format.html { render action: "new" }
        format.json { render json: @cell_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cell_types/1
  # PUT /cell_types/1.json
  def update
    @cell_type = CellType.find(params[:id])

    respond_to do |format|
      if @cell_type.update_attributes(params[:cell_type])
        format.html { redirect_to @cell_type, notice: 'Cell type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cell_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cell_types/1
  # DELETE /cell_types/1.json
  def destroy
    @cell_type = CellType.find(params[:id])
    @cell_type.destroy

    respond_to do |format|
      format.html { redirect_to cell_types_url }
      format.json { head :no_content }
    end
  end
end
