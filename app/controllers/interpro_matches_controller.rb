class InterproMatchesController < ApplicationController
  # GET /interpro_matches
  # GET /interpro_matches.json
  def index
    @interpro_matches = InterproMatch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interpro_matches }
    end
  end

  # GET /interpro_matches/1
  # GET /interpro_matches/1.json
  def show
    @interpro_match = InterproMatch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interpro_match }
    end
  end

  # GET /interpro_matches/new
  # GET /interpro_matches/new.json
  def new
    @interpro_match = InterproMatch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interpro_match }
    end
  end

  # GET /interpro_matches/1/edit
  def edit
    @interpro_match = InterproMatch.find(params[:id])
  end

  # POST /interpro_matches
  # POST /interpro_matches.json
  def create
    @interpro_match = InterproMatch.new(params[:interpro_match])

    respond_to do |format|
      if @interpro_match.save
        format.html { redirect_to @interpro_match, notice: 'Interpro match was successfully created.' }
        format.json { render json: @interpro_match, status: :created, location: @interpro_match }
      else
        format.html { render action: "new" }
        format.json { render json: @interpro_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interpro_matches/1
  # PUT /interpro_matches/1.json
  def update
    @interpro_match = InterproMatch.find(params[:id])

    respond_to do |format|
      if @interpro_match.update_attributes(params[:interpro_match])
        format.html { redirect_to @interpro_match, notice: 'Interpro match was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interpro_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interpro_matches/1
  # DELETE /interpro_matches/1.json
  def destroy
    @interpro_match = InterproMatch.find(params[:id])
    @interpro_match.destroy

    respond_to do |format|
      format.html { redirect_to interpro_matches_url }
      format.json { head :no_content }
    end
  end
end
