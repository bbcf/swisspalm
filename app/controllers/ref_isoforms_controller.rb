class RefIsoformsController < ApplicationController
  # GET /ref_isoforms
  # GET /ref_isoforms.json
  def index
    @ref_isoforms = RefIsoform.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ref_isoforms }
    end
  end

  # GET /ref_isoforms/1
  # GET /ref_isoforms/1.json
  def show
    @ref_isoform = RefIsoform.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ref_isoform }
    end
  end

  # GET /ref_isoforms/new
  # GET /ref_isoforms/new.json
  def new
    @ref_isoform = RefIsoform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ref_isoform }
    end
  end

  # GET /ref_isoforms/1/edit
  def edit
    @ref_isoform = RefIsoform.find(params[:id])
  end

  # POST /ref_isoforms
  # POST /ref_isoforms.json
  def create
    @ref_isoform = RefIsoform.new(params[:ref_isoform])

    respond_to do |format|
      if @ref_isoform.save
        format.html { redirect_to @ref_isoform, notice: 'Ref isoform was successfully created.' }
        format.json { render json: @ref_isoform, status: :created, location: @ref_isoform }
      else
        format.html { render action: "new" }
        format.json { render json: @ref_isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ref_isoforms/1
  # PUT /ref_isoforms/1.json
  def update
    @ref_isoform = RefIsoform.find(params[:id])

    respond_to do |format|
      if @ref_isoform.update_attributes(params[:ref_isoform])
        format.html { redirect_to @ref_isoform, notice: 'Ref isoform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ref_isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ref_isoforms/1
  # DELETE /ref_isoforms/1.json
  def destroy
    @ref_isoform = RefIsoform.find(params[:id])
    @ref_isoform.destroy

    respond_to do |format|
      format.html { redirect_to ref_isoforms_url }
      format.json { head :no_content }
    end
  end
end
