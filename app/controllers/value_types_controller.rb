class ValueTypesController < ApplicationController
  # GET /value_types
  # GET /value_types.json
  def index
    @value_types = ValueType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @value_types }
    end
  end

  # GET /value_types/1
  # GET /value_types/1.json
  def show
    @value_type = ValueType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @value_type }
    end
  end

  # GET /value_types/new
  # GET /value_types/new.json
  def new
    @value_type = ValueType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @value_type }
    end
  end

  # GET /value_types/1/edit
  def edit
    @value_type = ValueType.find(params[:id])
  end

  # POST /value_types
  # POST /value_types.json
  def create
    @value_type = ValueType.new(params[:value_type])

    respond_to do |format|
      if @value_type.save
        format.html { redirect_to @value_type, notice: 'Value type was successfully created.' }
        format.json { render json: @value_type, status: :created, location: @value_type }
      else
        format.html { render action: "new" }
        format.json { render json: @value_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /value_types/1
  # PUT /value_types/1.json
  def update
    @value_type = ValueType.find(params[:id])

    respond_to do |format|
      if @value_type.update_attributes(params[:value_type])
        format.html { redirect_to @value_type, notice: 'Value type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @value_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /value_types/1
  # DELETE /value_types/1.json
  def destroy
    @value_type = ValueType.find(params[:id])
    @value_type.destroy

    respond_to do |format|
      format.html { redirect_to value_types_url }
      format.json { head :no_content }
    end
  end
end
