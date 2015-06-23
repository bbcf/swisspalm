class OrthologuesController < ApplicationController
  # GET /orthologues
  # GET /orthologues.json
  def index
    @orthologues = Orthologue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orthologues }
    end
  end

  # GET /orthologues/1
  # GET /orthologues/1.json
  def show
    @orthologue = Orthologue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @orthologue }
    end
  end

  # GET /orthologues/new
  # GET /orthologues/new.json
  def new
    @orthologue = Orthologue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @orthologue }
    end
  end

  # GET /orthologues/1/edit
  def edit
    @orthologue = Orthologue.find(params[:id])
  end

  # POST /orthologues
  # POST /orthologues.json
  def create
    @orthologue = Orthologue.new(params[:orthologue])

    respond_to do |format|
      if @orthologue.save
        format.html { redirect_to @orthologue, notice: 'Orthologue was successfully created.' }
        format.json { render json: @orthologue, status: :created, location: @orthologue }
      else
        format.html { render action: "new" }
        format.json { render json: @orthologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orthologues/1
  # PUT /orthologues/1.json
  def update
    @orthologue = Orthologue.find(params[:id])

    respond_to do |format|
      if @orthologue.update_attributes(params[:orthologue])
        format.html { redirect_to @orthologue, notice: 'Orthologue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @orthologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orthologues/1
  # DELETE /orthologues/1.json
  def destroy
    @orthologue = Orthologue.find(params[:id])
    @orthologue.destroy

    respond_to do |format|
      format.html { redirect_to orthologues_url }
      format.json { head :no_content }
    end
  end
end
