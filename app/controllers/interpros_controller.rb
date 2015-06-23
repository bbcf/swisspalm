class InterprosController < ApplicationController
  # GET /interpros
  # GET /interpros.json
  def index
    @interpros = Interpro.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interpros }
    end
  end

  # GET /interpros/1
  # GET /interpros/1.json
  def show
    @interpro = Interpro.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interpro }
    end
  end

  # GET /interpros/new
  # GET /interpros/new.json
  def new
    @interpro = Interpro.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interpro }
    end
  end

  # GET /interpros/1/edit
  def edit
    @interpro = Interpro.find(params[:id])
  end

  # POST /interpros
  # POST /interpros.json
  def create
    @interpro = Interpro.new(params[:interpro])

    respond_to do |format|
      if @interpro.save
        format.html { redirect_to @interpro, notice: 'Interpro was successfully created.' }
        format.json { render json: @interpro, status: :created, location: @interpro }
      else
        format.html { render action: "new" }
        format.json { render json: @interpro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interpros/1
  # PUT /interpros/1.json
  def update
    @interpro = Interpro.find(params[:id])

    respond_to do |format|
      if @interpro.update_attributes(params[:interpro])
        format.html { redirect_to @interpro, notice: 'Interpro was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interpro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interpros/1
  # DELETE /interpros/1.json
  def destroy
    @interpro = Interpro.find(params[:id])
    @interpro.destroy

    respond_to do |format|
      format.html { redirect_to interpros_url }
      format.json { head :no_content }
    end
  end
end
