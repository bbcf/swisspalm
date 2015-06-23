class PhosphositeTypesController < ApplicationController
  # GET /phosphosite_types
  # GET /phosphosite_types.json
  def index
    @phosphosite_types = PhosphositeType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @phosphosite_types }
    end
  end

  # GET /phosphosite_types/1
  # GET /phosphosite_types/1.json
  def show
    @phosphosite_type = PhosphositeType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @phosphosite_type }
    end
  end

  # GET /phosphosite_types/new
  # GET /phosphosite_types/new.json
  def new
    @phosphosite_type = PhosphositeType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @phosphosite_type }
    end
  end

  # GET /phosphosite_types/1/edit
  def edit
    @phosphosite_type = PhosphositeType.find(params[:id])
  end

  # POST /phosphosite_types
  # POST /phosphosite_types.json
  def create
    @phosphosite_type = PhosphositeType.new(params[:phosphosite_type])

    respond_to do |format|
      if @phosphosite_type.save
        format.html { redirect_to @phosphosite_type, notice: 'Phosphosite type was successfully created.' }
        format.json { render json: @phosphosite_type, status: :created, location: @phosphosite_type }
      else
        format.html { render action: "new" }
        format.json { render json: @phosphosite_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /phosphosite_types/1
  # PUT /phosphosite_types/1.json
  def update
    @phosphosite_type = PhosphositeType.find(params[:id])

    respond_to do |format|
      if @phosphosite_type.update_attributes(params[:phosphosite_type])
        format.html { redirect_to @phosphosite_type, notice: 'Phosphosite type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @phosphosite_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phosphosite_types/1
  # DELETE /phosphosite_types/1.json
  def destroy
    @phosphosite_type = PhosphositeType.find(params[:id])
    @phosphosite_type.destroy

    respond_to do |format|
      format.html { redirect_to phosphosite_types_url }
      format.json { head :no_content }
    end
  end
end
