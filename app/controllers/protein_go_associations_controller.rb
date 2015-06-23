class ProteinGoAssociationsController < ApplicationController
  # GET /protein_go_associations
  # GET /protein_go_associations.json
  def index
    @protein_go_associations = ProteinGoAssociation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @protein_go_associations }
    end
  end

  # GET /protein_go_associations/1
  # GET /protein_go_associations/1.json
  def show
    @protein_go_association = ProteinGoAssociation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @protein_go_association }
    end
  end

  # GET /protein_go_associations/new
  # GET /protein_go_associations/new.json
  def new
    @protein_go_association = ProteinGoAssociation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @protein_go_association }
    end
  end

  # GET /protein_go_associations/1/edit
  def edit
    @protein_go_association = ProteinGoAssociation.find(params[:id])
  end

  # POST /protein_go_associations
  # POST /protein_go_associations.json
  def create
    @protein_go_association = ProteinGoAssociation.new(params[:protein_go_association])

    respond_to do |format|
      if @protein_go_association.save
        format.html { redirect_to @protein_go_association, notice: 'Protein go association was successfully created.' }
        format.json { render json: @protein_go_association, status: :created, location: @protein_go_association }
      else
        format.html { render action: "new" }
        format.json { render json: @protein_go_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /protein_go_associations/1
  # PUT /protein_go_associations/1.json
  def update
    @protein_go_association = ProteinGoAssociation.find(params[:id])

    respond_to do |format|
      if @protein_go_association.update_attributes(params[:protein_go_association])
        format.html { redirect_to @protein_go_association, notice: 'Protein go association was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @protein_go_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protein_go_associations/1
  # DELETE /protein_go_associations/1.json
  def destroy
    @protein_go_association = ProteinGoAssociation.find(params[:id])
    @protein_go_association.destroy

    respond_to do |format|
      format.html { redirect_to protein_go_associations_url }
      format.json { head :no_content }
    end
  end
end
