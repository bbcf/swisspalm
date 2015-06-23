class SubcellularFractionsController < ApplicationController

before_filter :authorize


  # GET /subcellular_fractions
  # GET /subcellular_fractions.json
  def index
    @subcellular_fractions = SubcellularFraction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subcellular_fractions }
    end
  end

  # GET /subcellular_fractions/1
  # GET /subcellular_fractions/1.json
  def show
    @subcellular_fraction = SubcellularFraction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subcellular_fraction }
    end
  end

  # GET /subcellular_fractions/new
  # GET /subcellular_fractions/new.json
  def new
    @subcellular_fraction = SubcellularFraction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subcellular_fraction }
    end
  end

  # GET /subcellular_fractions/1/edit
  def edit
    @subcellular_fraction = SubcellularFraction.find(params[:id])
  end

  # POST /subcellular_fractions
  # POST /subcellular_fractions.json
  def create
    @subcellular_fraction = SubcellularFraction.new(params[:subcellular_fraction])

    respond_to do |format|
      if @subcellular_fraction.save
        format.html { redirect_to @subcellular_fraction, notice: 'Subcellular fraction was successfully created.' }
        format.json { render json: @subcellular_fraction, status: :created, location: @subcellular_fraction }
      else
        format.html { render action: "new" }
        format.json { render json: @subcellular_fraction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subcellular_fractions/1
  # PUT /subcellular_fractions/1.json
  def update
    @subcellular_fraction = SubcellularFraction.find(params[:id])

    respond_to do |format|
      if @subcellular_fraction.update_attributes(params[:subcellular_fraction])
        format.html { redirect_to @subcellular_fraction, notice: 'Subcellular fraction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subcellular_fraction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subcellular_fractions/1
  # DELETE /subcellular_fractions/1.json
  def destroy
    @subcellular_fraction = SubcellularFraction.find(params[:id])
    @subcellular_fraction.destroy

    respond_to do |format|
      format.html { redirect_to subcellular_fractions_url }
      format.json { head :no_content }
    end
  end
end
