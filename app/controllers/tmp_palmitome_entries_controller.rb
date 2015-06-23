class TmpPalmitomeEntriesController < ApplicationController
  # GET /tmp_palmitome_entries
  # GET /tmp_palmitome_entries.json
  def index
    @tmp_palmitome_entries = TmpPalmitomeEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tmp_palmitome_entries }
    end
  end

  # GET /tmp_palmitome_entries/1
  # GET /tmp_palmitome_entries/1.json
  def show
    @tmp_palmitome_entry = TmpPalmitomeEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tmp_palmitome_entry }
    end
  end

  # GET /tmp_palmitome_entries/new
  # GET /tmp_palmitome_entries/new.json
  def new
    @tmp_palmitome_entry = TmpPalmitomeEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tmp_palmitome_entry }
    end
  end

  # GET /tmp_palmitome_entries/1/edit
  def edit
    @tmp_palmitome_entry = TmpPalmitomeEntry.find(params[:id])
  end

  # POST /tmp_palmitome_entries
  # POST /tmp_palmitome_entries.json
  def create
    @tmp_palmitome_entry = TmpPalmitomeEntry.new(params[:tmp_palmitome_entry])

    respond_to do |format|
      if @tmp_palmitome_entry.save
        format.html { redirect_to @tmp_palmitome_entry, notice: 'Tmp palmitome entry was successfully created.' }
        format.json { render json: @tmp_palmitome_entry, status: :created, location: @tmp_palmitome_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @tmp_palmitome_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tmp_palmitome_entries/1
  # PUT /tmp_palmitome_entries/1.json
  def update
    @tmp_palmitome_entry = TmpPalmitomeEntry.find(params[:id])

    respond_to do |format|
      if @tmp_palmitome_entry.update_attributes(params[:tmp_palmitome_entry])
        format.html { redirect_to @tmp_palmitome_entry, notice: 'Tmp palmitome entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tmp_palmitome_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tmp_palmitome_entries/1
  # DELETE /tmp_palmitome_entries/1.json
  def destroy
    @tmp_palmitome_entry = TmpPalmitomeEntry.find(params[:id])
    @tmp_palmitome_entry.destroy

    respond_to do |format|
      format.html { redirect_to tmp_palmitome_entries_url }
      format.json { head :no_content }
    end
  end
end
