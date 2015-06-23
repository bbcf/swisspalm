class SourceTypesController < ApplicationController
  # GET /source_types
  # GET /source_types.json
  def index
    @source_types = SourceType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @source_types }
    end
  end

  # GET /source_types/1
  # GET /source_types/1.json
  def show
    @source_type = SourceType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @source_type }
    end
  end

  # GET /source_types/new
  # GET /source_types/new.json
  def new
    @source_type = SourceType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @source_type }
    end
  end

  # GET /source_types/1/edit
  def edit
    @source_type = SourceType.find(params[:id])
  end

  # POST /source_types
  # POST /source_types.json
  def create
    @source_type = SourceType.new(params[:source_type])

    respond_to do |format|
      if @source_type.save
        format.html { redirect_to @source_type, notice: 'Source type was successfully created.' }
        format.json { render json: @source_type, status: :created, location: @source_type }
      else
        format.html { render action: "new" }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /source_types/1
  # PUT /source_types/1.json
  def update
    @source_type = SourceType.find(params[:id])

    respond_to do |format|
      if @source_type.update_attributes(params[:source_type])
        format.html { redirect_to @source_type, notice: 'Source type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_types/1
  # DELETE /source_types/1.json
  def destroy
    @source_type = SourceType.find(params[:id])
    @source_type.destroy

    respond_to do |format|
      format.html { redirect_to source_types_url }
      format.json { head :no_content }
    end
  end
end
