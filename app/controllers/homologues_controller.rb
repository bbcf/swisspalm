class HomologuesController < ApplicationController
  # GET /homologues
  # GET /homologues.json
  def index
    @homologues = Homologue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @homologues }
    end
  end

  # GET /homologues/1
  # GET /homologues/1.json
  def show
    @homologue = Homologue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @homologue }
    end
  end

  # GET /homologues/new
  # GET /homologues/new.json
  def new
    @homologue = Homologue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @homologue }
    end
  end

  # GET /homologues/1/edit
  def edit
    @homologue = Homologue.find(params[:id])
  end

  # POST /homologues
  # POST /homologues.json
  def create
    @homologue = Homologue.new(params[:homologue])

    respond_to do |format|
      if @homologue.save
        format.html { redirect_to @homologue, notice: 'Homologue was successfully created.' }
        format.json { render json: @homologue, status: :created, location: @homologue }
      else
        format.html { render action: "new" }
        format.json { render json: @homologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /homologues/1
  # PUT /homologues/1.json
  def update
    @homologue = Homologue.find(params[:id])

    respond_to do |format|
      if @homologue.update_attributes(params[:homologue])
        format.html { redirect_to @homologue, notice: 'Homologue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @homologue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /homologues/1
  # DELETE /homologues/1.json
  def destroy
    @homologue = Homologue.find(params[:id])
    @homologue.destroy

    respond_to do |format|
      format.html { redirect_to homologues_url }
      format.json { head :no_content }
    end
  end
end
