class PalmitomeEntriesController < ApplicationController
  # GET /palmitome_entries
  # GET /palmitome_entries.json
  def index
    @palmitome_entries = PalmitomeEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @palmitome_entries }
    end
  end

  # GET /palmitome_entries/1
  # GET /palmitome_entries/1.json
  def show
    @palmitome_entry = PalmitomeEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @palmitome_entry }
    end
  end

  # GET /palmitome_entries/new
  # GET /palmitome_entries/new.json
  def new
    @palmitome_entry = PalmitomeEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @palmitome_entry }
    end
  end

  # GET /palmitome_entries/1/edit
  def edit
    @palmitome_entry = PalmitomeEntry.find(params[:id])
  end

  # POST /palmitome_entries
  # POST /palmitome_entries.json
  def create
    @palmitome_entry = PalmitomeEntry.new(params[:palmitome_entry])

    respond_to do |format|
      if @palmitome_entry.save
        format.html { redirect_to @palmitome_entry, notice: 'Palmitome entry was successfully created.' }
        format.json { render json: @palmitome_entry, status: :created, location: @palmitome_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @palmitome_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /palmitome_entries/1
  # PUT /palmitome_entries/1.json
  def update
    @palmitome_entry = PalmitomeEntry.find(params[:id])

    respond_to do |format|
      if @palmitome_entry.update_attributes(params[:palmitome_entry])
        format.html { redirect_to @palmitome_entry, notice: 'Palmitome entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @palmitome_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /palmitome_entries/1
  # DELETE /palmitome_entries/1.json
  def destroy
    @palmitome_entry = PalmitomeEntry.find(params[:id])
    @palmitome_entry.destroy

    respond_to do |format|
      format.html { redirect_to palmitome_entries_url }
      format.json { head :no_content }
    end
  end
end
