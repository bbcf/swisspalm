class CysteinesController < ApplicationController
  # GET /cysteines
  # GET /cysteines.json
  def index
    @cysteines = Cysteine.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cysteines }
    end
  end

  # GET /cysteines/1
  # GET /cysteines/1.json
  def show
    @cysteine = Cysteine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cysteine }
    end
  end

  # GET /cysteines/new
  # GET /cysteines/new.json
  def new
    @cysteine = Cysteine.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cysteine }
    end
  end

  # GET /cysteines/1/edit
  def edit
    @cysteine = Cysteine.find(params[:id])
  end

  # POST /cysteines
  # POST /cysteines.json
  def create
    @cysteine = Cysteine.new(params[:cysteine])

    respond_to do |format|
      if @cysteine.save
        format.html { redirect_to @cysteine, notice: 'Cysteine was successfully created.' }
        format.json { render json: @cysteine, status: :created, location: @cysteine }
      else
        format.html { render action: "new" }
        format.json { render json: @cysteine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cysteines/1
  # PUT /cysteines/1.json
  def update
    @cysteine = Cysteine.find(params[:id])

    respond_to do |format|
      if @cysteine.update_attributes(params[:cysteine])
        format.html { redirect_to @cysteine, notice: 'Cysteine was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cysteine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cysteines/1
  # DELETE /cysteines/1.json
  def destroy
    @cysteine = Cysteine.find(params[:id])
    @cysteine.destroy

    respond_to do |format|
      format.html { redirect_to cysteines_url }
      format.json { head :no_content }
    end
  end
end
