class OmaPairsController < ApplicationController
  # GET /oma_pairs
  # GET /oma_pairs.json
  def index
    @oma_pairs = OmaPair.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @oma_pairs }
    end
  end

  # GET /oma_pairs/1
  # GET /oma_pairs/1.json
  def show
    @oma_pair = OmaPair.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @oma_pair }
    end
  end

  # GET /oma_pairs/new
  # GET /oma_pairs/new.json
  def new
    @oma_pair = OmaPair.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oma_pair }
    end
  end

  # GET /oma_pairs/1/edit
  def edit
    @oma_pair = OmaPair.find(params[:id])
  end

  # POST /oma_pairs
  # POST /oma_pairs.json
  def create
    @oma_pair = OmaPair.new(params[:oma_pair])

    respond_to do |format|
      if @oma_pair.save
        format.html { redirect_to @oma_pair, notice: 'Oma pair was successfully created.' }
        format.json { render json: @oma_pair, status: :created, location: @oma_pair }
      else
        format.html { render action: "new" }
        format.json { render json: @oma_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /oma_pairs/1
  # PUT /oma_pairs/1.json
  def update
    @oma_pair = OmaPair.find(params[:id])

    respond_to do |format|
      if @oma_pair.update_attributes(params[:oma_pair])
        format.html { redirect_to @oma_pair, notice: 'Oma pair was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @oma_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oma_pairs/1
  # DELETE /oma_pairs/1.json
  def destroy
    @oma_pair = OmaPair.find(params[:id])
    @oma_pair.destroy

    respond_to do |format|
      format.html { redirect_to oma_pairs_url }
      format.json { head :no_content }
    end
  end
end
