class TopologiesController < ApplicationController
  # GET /topologies
  # GET /topologies.json
  def index
    @topologies = Topology.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topologies }
    end
  end

  # GET /topologies/1
  # GET /topologies/1.json
  def show
    @topology = Topology.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topology }
    end
  end

  # GET /topologies/new
  # GET /topologies/new.json
  def new
    @topology = Topology.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topology }
    end
  end

  # GET /topologies/1/edit
  def edit
    @topology = Topology.find(params[:id])
  end

  # POST /topologies
  # POST /topologies.json
  def create
    @topology = Topology.new(params[:topology])

    respond_to do |format|
      if @topology.save
        format.html { redirect_to @topology, notice: 'Topology was successfully created.' }
        format.json { render json: @topology, status: :created, location: @topology }
      else
        format.html { render action: "new" }
        format.json { render json: @topology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /topologies/1
  # PUT /topologies/1.json
  def update
    @topology = Topology.find(params[:id])

    respond_to do |format|
      if @topology.update_attributes(params[:topology])
        format.html { redirect_to @topology, notice: 'Topology was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topologies/1
  # DELETE /topologies/1.json
  def destroy
    @topology = Topology.find(params[:id])
    @topology.destroy

    respond_to do |format|
      format.html { redirect_to topologies_url }
      format.json { head :no_content }
    end
  end
end
