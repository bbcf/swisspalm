class PatIsoformsController < ApplicationController
  # GET /pat_isoforms
  # GET /pat_isoforms.json
  def index
    @pat_isoforms = PatIsoform.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pat_isoforms }
    end
  end

  # GET /pat_isoforms/1
  # GET /pat_isoforms/1.json
  def show
    @pat_isoform = PatIsoform.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pat_isoform }
    end
  end

  # GET /pat_isoforms/new
  # GET /pat_isoforms/new.json
  def new
    @pat_isoform = PatIsoform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pat_isoform }
    end
  end

  # GET /pat_isoforms/1/edit
  def edit
    @pat_isoform = PatIsoform.find(params[:id])
  end

  # POST /pat_isoforms
  # POST /pat_isoforms.json
  def create
    @pat_isoform = PatIsoform.new(params[:pat_isoform])

    respond_to do |format|
      if @pat_isoform.save
        format.html { redirect_to @pat_isoform, notice: 'Pat isoform was successfully created.' }
        format.json { render json: @pat_isoform, status: :created, location: @pat_isoform }
      else
        format.html { render action: "new" }
        format.json { render json: @pat_isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pat_isoforms/1
  # PUT /pat_isoforms/1.json
  def update
    @pat_isoform = PatIsoform.find(params[:id])

    respond_to do |format|
      if @pat_isoform.update_attributes(params[:pat_isoform])
        format.html { redirect_to @pat_isoform, notice: 'Pat isoform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pat_isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pat_isoforms/1
  # DELETE /pat_isoforms/1.json
  def destroy
    @pat_isoform = PatIsoform.find(params[:id])
    @pat_isoform.destroy

    respond_to do |format|
      format.html { redirect_to pat_isoforms_url }
      format.json { head :no_content }
    end
  end
end
