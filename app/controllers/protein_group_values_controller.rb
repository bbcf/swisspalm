class ProteinGroupValuesController < ApplicationController
  # GET /protein_group_values
  # GET /protein_group_values.json
  def index
    @protein_group_values = ProteinGroupValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @protein_group_values }
    end
  end

  # GET /protein_group_values/1
  # GET /protein_group_values/1.json
  def show
    @protein_group_value = ProteinGroupValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protein_group_value }
    end
  end

  # GET /protein_group_values/new
  # GET /protein_group_values/new.json
  def new
    @protein_group_value = ProteinGroupValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protein_group_value }
    end
  end

  # GET /protein_group_values/1/edit
  def edit
    @protein_group_value = ProteinGroupValue.find(params[:id])
  end

  # POST /protein_group_values
  # POST /protein_group_values.json
  def create
    @protein_group_value = ProteinGroupValue.new(params[:protein_group_value])

    respond_to do |format|
      if @protein_group_value.save
        format.html { redirect_to @protein_group_value, notice: 'Protein group value was successfully created.' }
        format.json { render json: @protein_group_value, status: :created, location: @protein_group_value }
      else
        format.html { render action: "new" }
        format.json { render json: @protein_group_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /protein_group_values/1
  # PUT /protein_group_values/1.json
  def update
    @protein_group_value = ProteinGroupValue.find(params[:id])

    respond_to do |format|
      if @protein_group_value.update_attributes(params[:protein_group_value])
        format.html { redirect_to @protein_group_value, notice: 'Protein group value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @protein_group_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protein_group_values/1
  # DELETE /protein_group_values/1.json
  def destroy
    @protein_group_value = ProteinGroupValue.find(params[:id])
    @protein_group_value.destroy

    respond_to do |format|
      format.html { redirect_to protein_group_values_url }
      format.json { head :no_content }
    end
  end
end
