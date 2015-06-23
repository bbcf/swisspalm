class PhosphositeFeaturesController < ApplicationController
  # GET /phosphosite_features
  # GET /phosphosite_features.json
  def index
    @phosphosite_features = PhosphositeFeature.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @phosphosite_features }
    end
  end

  # GET /phosphosite_features/1
  # GET /phosphosite_features/1.json
  def show
    @phosphosite_feature = PhosphositeFeature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @phosphosite_feature }
    end
  end

  # GET /phosphosite_features/new
  # GET /phosphosite_features/new.json
  def new
    @phosphosite_feature = PhosphositeFeature.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @phosphosite_feature }
    end
  end

  # GET /phosphosite_features/1/edit
  def edit
    @phosphosite_feature = PhosphositeFeature.find(params[:id])
  end

  # POST /phosphosite_features
  # POST /phosphosite_features.json
  def create
    @phosphosite_feature = PhosphositeFeature.new(params[:phosphosite_feature])

    respond_to do |format|
      if @phosphosite_feature.save
        format.html { redirect_to @phosphosite_feature, notice: 'Phosphosite feature was successfully created.' }
        format.json { render json: @phosphosite_feature, status: :created, location: @phosphosite_feature }
      else
        format.html { render action: "new" }
        format.json { render json: @phosphosite_feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /phosphosite_features/1
  # PUT /phosphosite_features/1.json
  def update
    @phosphosite_feature = PhosphositeFeature.find(params[:id])

    respond_to do |format|
      if @phosphosite_feature.update_attributes(params[:phosphosite_feature])
        format.html { redirect_to @phosphosite_feature, notice: 'Phosphosite feature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @phosphosite_feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phosphosite_features/1
  # DELETE /phosphosite_features/1.json
  def destroy
    @phosphosite_feature = PhosphositeFeature.find(params[:id])
    @phosphosite_feature.destroy

    respond_to do |format|
      format.html { redirect_to phosphosite_features_url }
      format.json { head :no_content }
    end
  end
end
