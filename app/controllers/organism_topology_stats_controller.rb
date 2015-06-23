class OrganismTopologyStatsController < ApplicationController
  # GET /organism_topology_stats
  # GET /organism_topology_stats.json
  def index
    @organism_topology_stats = OrganismTopologyStat.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organism_topology_stats }
    end
  end

  # GET /organism_topology_stats/1
  # GET /organism_topology_stats/1.json
  def show
    @organism_topology_stat = OrganismTopologyStat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @organism_topology_stat }
    end
  end

  # GET /organism_topology_stats/new
  # GET /organism_topology_stats/new.json
  def new
    @organism_topology_stat = OrganismTopologyStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organism_topology_stat }
    end
  end

  # GET /organism_topology_stats/1/edit
  def edit
    @organism_topology_stat = OrganismTopologyStat.find(params[:id])
  end

  # POST /organism_topology_stats
  # POST /organism_topology_stats.json
  def create
    @organism_topology_stat = OrganismTopologyStat.new(params[:organism_topology_stat])

    respond_to do |format|
      if @organism_topology_stat.save
        format.html { redirect_to @organism_topology_stat, notice: 'Organism topology stat was successfully created.' }
        format.json { render json: @organism_topology_stat, status: :created, location: @organism_topology_stat }
      else
        format.html { render action: "new" }
        format.json { render json: @organism_topology_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organism_topology_stats/1
  # PUT /organism_topology_stats/1.json
  def update
    @organism_topology_stat = OrganismTopologyStat.find(params[:id])

    respond_to do |format|
      if @organism_topology_stat.update_attributes(params[:organism_topology_stat])
        format.html { redirect_to @organism_topology_stat, notice: 'Organism topology stat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism_topology_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organism_topology_stats/1
  # DELETE /organism_topology_stats/1.json
  def destroy
    @organism_topology_stat = OrganismTopologyStat.find(params[:id])
    @organism_topology_stat.destroy

    respond_to do |format|
      format.html { redirect_to organism_topology_stats_url }
      format.json { head :no_content }
    end
  end
end
