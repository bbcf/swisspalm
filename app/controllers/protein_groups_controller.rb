class ProteinGroupsController < ApplicationController
  # GET /protein_groups
  # GET /protein_groups.json
  def index
    @protein_groups = ProteinGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @protein_groups }
    end
  end

  # GET /protein_groups/1
  # GET /protein_groups/1.json
  def show
    @protein_group = ProteinGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protein_group }
    end
  end

  # GET /protein_groups/new
  # GET /protein_groups/new.json
  def new
    @protein_group = ProteinGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protein_group }
    end
  end

  # GET /protein_groups/1/edit
  def edit
    @protein_group = ProteinGroup.find(params[:id])
  end

  # POST /protein_groups
  # POST /protein_groups.json
  def create
    @protein_group = ProteinGroup.new(params[:protein_group])

    respond_to do |format|
      if @protein_group.save
        format.html { redirect_to @protein_group, notice: 'Protein group was successfully created.' }
        format.json { render json: @protein_group, status: :created, location: @protein_group }
      else
        format.html { render action: "new" }
        format.json { render json: @protein_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /protein_groups/1
  # PUT /protein_groups/1.json
  def update
    @protein_group = ProteinGroup.find(params[:id])

    respond_to do |format|
      if @protein_group.update_attributes(params[:protein_group])
        format.html { redirect_to @protein_group, notice: 'Protein group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @protein_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protein_groups/1
  # DELETE /protein_groups/1.json
  def destroy
    @protein_group = ProteinGroup.find(params[:id])
    @protein_group.destroy

    respond_to do |format|
      format.html { redirect_to protein_groups_url }
      format.json { head :no_content }
    end
  end
end
