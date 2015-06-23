class VerbTypesController < ApplicationController
  # GET /verb_types
  # GET /verb_types.json
  def index
    @verb_types = VerbType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @verb_types }
    end
  end

  # GET /verb_types/1
  # GET /verb_types/1.json
  def show
    @verb_type = VerbType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @verb_type }
    end
  end

  # GET /verb_types/new
  # GET /verb_types/new.json
  def new
    @verb_type = VerbType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @verb_type }
    end
  end

  # GET /verb_types/1/edit
  def edit
    @verb_type = VerbType.find(params[:id])
  end

  # POST /verb_types
  # POST /verb_types.json
  def create
    @verb_type = VerbType.new(params[:verb_type])

    respond_to do |format|
      if @verb_type.save
        format.html { redirect_to @verb_type, notice: 'Verb type was successfully created.' }
        format.json { render json: @verb_type, status: :created, location: @verb_type }
      else
        format.html { render action: "new" }
        format.json { render json: @verb_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /verb_types/1
  # PUT /verb_types/1.json
  def update
    @verb_type = VerbType.find(params[:id])

    respond_to do |format|
      if @verb_type.update_attributes(params[:verb_type])
        format.html { redirect_to @verb_type, notice: 'Verb type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @verb_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /verb_types/1
  # DELETE /verb_types/1.json
  def destroy
    @verb_type = VerbType.find(params[:id])
    @verb_type.destroy

    respond_to do |format|
      format.html { redirect_to verb_types_url }
      format.json { head :no_content }
    end
  end
end
