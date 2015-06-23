class TechniqueClassesController < ApplicationController
  # GET /technique_classes
  # GET /technique_classes.json
  def index
    @technique_classes = TechniqueClass.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technique_classes }
    end
  end

  # GET /technique_classes/1
  # GET /technique_classes/1.json
  def show
    @technique_class = TechniqueClass.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technique_class }
    end
  end

  # GET /technique_classes/new
  # GET /technique_classes/new.json
  def new
    @technique_class = TechniqueClass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technique_class }
    end
  end

  # GET /technique_classes/1/edit
  def edit
    @technique_class = TechniqueClass.find(params[:id])
  end

  # POST /technique_classes
  # POST /technique_classes.json
  def create
    @technique_class = TechniqueClass.new(params[:technique_class])

    respond_to do |format|
      if @technique_class.save
        format.html { redirect_to @technique_class, notice: 'Technique class was successfully created.' }
        format.json { render json: @technique_class, status: :created, location: @technique_class }
      else
        format.html { render action: "new" }
        format.json { render json: @technique_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technique_classes/1
  # PUT /technique_classes/1.json
  def update
    @technique_class = TechniqueClass.find(params[:id])

    respond_to do |format|
      if @technique_class.update_attributes(params[:technique_class])
        format.html { redirect_to @technique_class, notice: 'Technique class was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @technique_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technique_classes/1
  # DELETE /technique_classes/1.json
  def destroy
    @technique_class = TechniqueClass.find(params[:id])
    @technique_class.destroy

    respond_to do |format|
      format.html { redirect_to technique_classes_url }
      format.json { head :no_content }
    end
  end
end
