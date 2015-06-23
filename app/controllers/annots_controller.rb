class AnnotsController < ApplicationController
  # GET /annots
  # GET /annots.json
  def index
    @annots = Annot.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @annots }
    end
  end

  # GET /annots/1
  # GET /annots/1.json
  def show
    @annot = Annot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @annot }
    end
  end

  # GET /annots/new
  # GET /annots/new.json
  def new
    @annot = Annot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @annot }
    end
  end

  # GET /annots/1/edit
  def edit
    @annot = Annot.find(params[:id])
  end

  # POST /annots
  # POST /annots.json
  def create
    @annot = Annot.new(params[:annot])

    respond_to do |format|
      if @annot.save
        format.html { redirect_to @annot, notice: 'Annot was successfully created.' }
        format.json { render json: @annot, status: :created, location: @annot }
      else
        format.html { render action: "new" }
        format.json { render json: @annot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /annots/1
  # PUT /annots/1.json
  def update
    @annot = Annot.find(params[:id])

    respond_to do |format|
      if @annot.update_attributes(params[:annot])
        format.html { redirect_to @annot, notice: 'Annot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @annot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /annots/1
  # DELETE /annots/1.json
  def destroy
    @annot = Annot.find(params[:id])
    @annot.destroy

    respond_to do |format|
      format.html { redirect_to annots_url }
      format.json { head :no_content }
    end
  end
end
