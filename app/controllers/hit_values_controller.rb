class HitValuesController < ApplicationController
  # GET /hit_values
  # GET /hit_values.json
  def index
    @hit_values = HitValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hit_values }
    end
  end

  # GET /hit_values/1
  # GET /hit_values/1.json
  def show
    @hit_value = HitValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hit_value }
    end
  end

  # GET /hit_values/new
  # GET /hit_values/new.json
  def new
    @hit_value = HitValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hit_value }
    end
  end

  # GET /hit_values/1/edit
  def edit
    @hit_value = HitValue.find(params[:id])
  end

  # POST /hit_values
  # POST /hit_values.json
  def create
    @hit_value = HitValue.new(params[:hit_value])

    respond_to do |format|
      if @hit_value.save
        format.html { redirect_to @hit_value, notice: 'Hit value was successfully created.' }
        format.json { render json: @hit_value, status: :created, location: @hit_value }
      else
        format.html { render action: "new" }
        format.json { render json: @hit_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hit_values/1
  # PUT /hit_values/1.json
  def update
    @hit_value = HitValue.find(params[:id])

    respond_to do |format|
      if @hit_value.update_attributes(params[:hit_value])
        format.html { redirect_to @hit_value, notice: 'Hit value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hit_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hit_values/1
  # DELETE /hit_values/1.json
  def destroy
    @hit_value = HitValue.find(params[:id])
    @hit_value.destroy

    respond_to do |format|
      format.html { redirect_to hit_values_url }
      format.json { head :no_content }
    end
  end
end
