class TechniquesController < ApplicationController

before_filter :authorize

  # GET /techniques
  # GET /techniques.json
  def index
    @techniques = Technique.all

    respond_to do |format|
      format.html # index.html.erb
      format.text { render text: @techniques.map{|e| "#{e.id}\t#{e.name}"}.join("\n")}
      format.json { render json: @techniques }
    end
  end

  # GET /techniques/1
  # GET /techniques/1.json
  def show
    @technique = Technique.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technique }
    end
  end

  # GET /techniques/new
  # GET /techniques/new.json
  def new
    @technique = Technique.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technique }
    end
  end

  # GET /techniques/1/edit
  def edit
    @technique = Technique.find(params[:id])
  end

  # POST /techniques
  # POST /techniques.json
  def create
    @technique = Technique.new(params[:technique])

    respond_to do |format|
      if @technique.save
        format.html { redirect_to @technique, notice: 'Technique was successfully created.' }
        format.json { render json: @technique, status: :created, location: @technique }
      else
        format.html { render action: "new" }
        format.json { render json: @technique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /techniques/1
  # PUT /techniques/1.json
  def update
    @technique = Technique.find(params[:id])

    respond_to do |format|
      if @technique.update_attributes(params[:technique])
        format.html { redirect_to @technique, notice: 'Technique was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @technique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /techniques/1
  # DELETE /techniques/1.json
  def destroy
    @technique = Technique.find(params[:id])
    @technique.destroy

    respond_to do |format|
      format.html { redirect_to techniques_url }
      format.json { head :no_content }
    end
  end
end
