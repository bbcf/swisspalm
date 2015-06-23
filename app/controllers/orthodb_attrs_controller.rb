class OrthodbAttrsController < ApplicationController
  # GET /orthodb_attrs
  # GET /orthodb_attrs.json
  def index
    @orthodb_attrs = OrthodbAttr.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orthodb_attrs }
    end
  end

  # GET /orthodb_attrs/1
  # GET /orthodb_attrs/1.json
  def show
    @orthodb_attr = OrthodbAttr.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @orthodb_attr }
    end
  end

  # GET /orthodb_attrs/new
  # GET /orthodb_attrs/new.json
  def new
    @orthodb_attr = OrthodbAttr.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @orthodb_attr }
    end
  end

  # GET /orthodb_attrs/1/edit
  def edit
    @orthodb_attr = OrthodbAttr.find(params[:id])
  end

  # POST /orthodb_attrs
  # POST /orthodb_attrs.json
  def create
    @orthodb_attr = OrthodbAttr.new(params[:orthodb_attr])

    respond_to do |format|
      if @orthodb_attr.save
        format.html { redirect_to @orthodb_attr, notice: 'Orthodb attr was successfully created.' }
        format.json { render json: @orthodb_attr, status: :created, location: @orthodb_attr }
      else
        format.html { render action: "new" }
        format.json { render json: @orthodb_attr.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orthodb_attrs/1
  # PUT /orthodb_attrs/1.json
  def update
    @orthodb_attr = OrthodbAttr.find(params[:id])

    respond_to do |format|
      if @orthodb_attr.update_attributes(params[:orthodb_attr])
        format.html { redirect_to @orthodb_attr, notice: 'Orthodb attr was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @orthodb_attr.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orthodb_attrs/1
  # DELETE /orthodb_attrs/1.json
  def destroy
    @orthodb_attr = OrthodbAttr.find(params[:id])
    @orthodb_attr.destroy

    respond_to do |format|
      format.html { redirect_to orthodb_attrs_url }
      format.json { head :no_content }
    end
  end
end
