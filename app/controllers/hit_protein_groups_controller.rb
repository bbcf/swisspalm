class HitProteinGroupsController < ApplicationController
  # GET /hit_protein_groups
  # GET /hit_protein_groups.json
  def index
    @hit_protein_groups = HitProteinGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hit_protein_groups }
    end
  end

  # GET /hit_protein_groups/1
  # GET /hit_protein_groups/1.json
  def show
    @hit_protein_group = HitProteinGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hit_protein_group }
    end
  end

  # GET /hit_protein_groups/new
  # GET /hit_protein_groups/new.json
  def new
    @hit_protein_group = HitProteinGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hit_protein_group }
    end
  end

  # GET /hit_protein_groups/1/edit
  def edit
    @hit_protein_group = HitProteinGroup.find(params[:id])
  end

  # POST /hit_protein_groups
  # POST /hit_protein_groups.json
  def create
    @hit_protein_group = HitProteinGroup.new(params[:hit_protein_group])

    respond_to do |format|
      if @hit_protein_group.save
        format.html { redirect_to @hit_protein_group, notice: 'Hit protein group was successfully created.' }
        format.json { render json: @hit_protein_group, status: :created, location: @hit_protein_group }
      else
        format.html { render action: "new" }
        format.json { render json: @hit_protein_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hit_protein_groups/1
  # PUT /hit_protein_groups/1.json
  def update
    @hit_protein_group = HitProteinGroup.find(params[:id])

    respond_to do |format|
      if @hit_protein_group.update_attributes(params[:hit_protein_group])
        format.html { redirect_to @hit_protein_group, notice: 'Hit protein group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hit_protein_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hit_protein_groups/1
  # DELETE /hit_protein_groups/1.json
  def destroy
    @hit_protein_group = HitProteinGroup.find(params[:id])
    @hit_protein_group.destroy

    respond_to do |format|
      format.html { redirect_to hit_protein_groups_url }
      format.json { head :no_content }
    end
  end
end
