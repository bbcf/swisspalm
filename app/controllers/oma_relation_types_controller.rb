class OmaRelationTypesController < ApplicationController
  # GET /oma_relation_types
  # GET /oma_relation_types.json
  def index
    @oma_relation_types = OmaRelationType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @oma_relation_types }
    end
  end

  # GET /oma_relation_types/1
  # GET /oma_relation_types/1.json
  def show
    @oma_relation_type = OmaRelationType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @oma_relation_type }
    end
  end

  # GET /oma_relation_types/new
  # GET /oma_relation_types/new.json
  def new
    @oma_relation_type = OmaRelationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oma_relation_type }
    end
  end

  # GET /oma_relation_types/1/edit
  def edit
    @oma_relation_type = OmaRelationType.find(params[:id])
  end

  # POST /oma_relation_types
  # POST /oma_relation_types.json
  def create
    @oma_relation_type = OmaRelationType.new(params[:oma_relation_type])

    respond_to do |format|
      if @oma_relation_type.save
        format.html { redirect_to @oma_relation_type, notice: 'Oma relation type was successfully created.' }
        format.json { render json: @oma_relation_type, status: :created, location: @oma_relation_type }
      else
        format.html { render action: "new" }
        format.json { render json: @oma_relation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /oma_relation_types/1
  # PUT /oma_relation_types/1.json
  def update
    @oma_relation_type = OmaRelationType.find(params[:id])

    respond_to do |format|
      if @oma_relation_type.update_attributes(params[:oma_relation_type])
        format.html { redirect_to @oma_relation_type, notice: 'Oma relation type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @oma_relation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oma_relation_types/1
  # DELETE /oma_relation_types/1.json
  def destroy
    @oma_relation_type = OmaRelationType.find(params[:id])
    @oma_relation_type.destroy

    respond_to do |format|
      format.html { redirect_to oma_relation_types_url }
      format.json { head :no_content }
    end
  end
end
