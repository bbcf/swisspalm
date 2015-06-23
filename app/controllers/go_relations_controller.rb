class GoRelationsController < ApplicationController
  # GET /go_relations
  # GET /go_relations.json
  def index
    @go_relations = GoRelation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @go_relations }
    end
  end

  # GET /go_relations/1
  # GET /go_relations/1.json
  def show
    @go_relation = GoRelation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @go_relation }
    end
  end

  # GET /go_relations/new
  # GET /go_relations/new.json
  def new
    @go_relation = GoRelation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @go_relation }
    end
  end

  # GET /go_relations/1/edit
  def edit
    @go_relation = GoRelation.find(params[:id])
  end

  # POST /go_relations
  # POST /go_relations.json
  def create
    @go_relation = GoRelation.new(params[:go_relation])

    respond_to do |format|
      if @go_relation.save
        format.html { redirect_to @go_relation, notice: 'Go relation was successfully created.' }
        format.json { render json: @go_relation, status: :created, location: @go_relation }
      else
        format.html { render action: "new" }
        format.json { render json: @go_relation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /go_relations/1
  # PUT /go_relations/1.json
  def update
    @go_relation = GoRelation.find(params[:id])

    respond_to do |format|
      if @go_relation.update_attributes(params[:go_relation])
        format.html { redirect_to @go_relation, notice: 'Go relation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @go_relation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /go_relations/1
  # DELETE /go_relations/1.json
  def destroy
    @go_relation = GoRelation.find(params[:id])
    @go_relation.destroy

    respond_to do |format|
      format.html { redirect_to go_relations_url }
      format.json { head :no_content }
    end
  end
end
