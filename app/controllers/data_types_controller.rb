class DataTypesController < ApplicationController
  # GET /data_types
  # GET /data_types.json
  def index
    @data_types = DataType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_types }
    end
  end

  # GET /data_types/1
  # GET /data_types/1.json
  def show
    @data_type = DataType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @data_type }
    end
  end

  # GET /data_types/new
  # GET /data_types/new.json
  def new
    @data_type = DataType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @data_type }
    end
  end

  # GET /data_types/1/edit
  def edit
    @data_type = DataType.find(params[:id])
  end

  # POST /data_types
  # POST /data_types.json
  def create
    @data_type = DataType.new(params[:data_type])

    respond_to do |format|
      if @data_type.save
        format.html { redirect_to @data_type, notice: 'Data type was successfully created.' }
        format.json { render json: @data_type, status: :created, location: @data_type }
      else
        format.html { render action: "new" }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_types/1
  # PUT /data_types/1.json
  def update
    @data_type = DataType.find(params[:id])

    respond_to do |format|
      if @data_type.update_attributes(params[:data_type])
        format.html { redirect_to @data_type, notice: 'Data type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_types/1
  # DELETE /data_types/1.json
  def destroy
    @data_type = DataType.find(params[:id])
    @data_type.destroy

    respond_to do |format|
      format.html { redirect_to data_types_url }
      format.json { head :no_content }
    end
  end
end
