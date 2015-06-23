class TechniqueCategoriesController < ApplicationController
  # GET /technique_categories
  # GET /technique_categories.json
  def index
    @technique_categories = TechniqueCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technique_categories }
    end
  end

  # GET /technique_categories/1
  # GET /technique_categories/1.json
  def show
    @technique_category = TechniqueCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technique_category }
    end
  end

  # GET /technique_categories/new
  # GET /technique_categories/new.json
  def new
    @technique_category = TechniqueCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technique_category }
    end
  end

  # GET /technique_categories/1/edit
  def edit
    @technique_category = TechniqueCategory.find(params[:id])
  end

  # POST /technique_categories
  # POST /technique_categories.json
  def create
    @technique_category = TechniqueCategory.new(params[:technique_category])

    respond_to do |format|
      if @technique_category.save
        format.html { redirect_to @technique_category, notice: 'Technique category was successfully created.' }
        format.json { render json: @technique_category, status: :created, location: @technique_category }
      else
        format.html { render action: "new" }
        format.json { render json: @technique_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technique_categories/1
  # PUT /technique_categories/1.json
  def update
    @technique_category = TechniqueCategory.find(params[:id])

    respond_to do |format|
      if @technique_category.update_attributes(params[:technique_category])
        format.html { redirect_to @technique_category, notice: 'Technique category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @technique_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technique_categories/1
  # DELETE /technique_categories/1.json
  def destroy
    @technique_category = TechniqueCategory.find(params[:id])
    @technique_category.destroy

    respond_to do |format|
      format.html { redirect_to technique_categories_url }
      format.json { head :no_content }
    end
  end
end
