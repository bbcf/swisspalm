class GoTermEnrichmentsController < ApplicationController
  # GET /go_term_enrichments
  # GET /go_term_enrichments.json
  def index
    @go_term_enrichments = GoTermEnrichment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @go_term_enrichments }
    end
  end

  # GET /go_term_enrichments/1
  # GET /go_term_enrichments/1.json
  def show
    @go_term_enrichment = GoTermEnrichment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @go_term_enrichment }
    end
  end

  # GET /go_term_enrichments/new
  # GET /go_term_enrichments/new.json
  def new
    @go_term_enrichment = GoTermEnrichment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @go_term_enrichment }
    end
  end

  # GET /go_term_enrichments/1/edit
  def edit
    @go_term_enrichment = GoTermEnrichment.find(params[:id])
  end

  # POST /go_term_enrichments
  # POST /go_term_enrichments.json
  def create
    @go_term_enrichment = GoTermEnrichment.new(params[:go_term_enrichment])

    respond_to do |format|
      if @go_term_enrichment.save
        format.html { redirect_to @go_term_enrichment, notice: 'Go term enrichment was successfully created.' }
        format.json { render json: @go_term_enrichment, status: :created, location: @go_term_enrichment }
      else
        format.html { render action: "new" }
        format.json { render json: @go_term_enrichment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /go_term_enrichments/1
  # PUT /go_term_enrichments/1.json
  def update
    @go_term_enrichment = GoTermEnrichment.find(params[:id])

    respond_to do |format|
      if @go_term_enrichment.update_attributes(params[:go_term_enrichment])
        format.html { redirect_to @go_term_enrichment, notice: 'Go term enrichment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @go_term_enrichment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /go_term_enrichments/1
  # DELETE /go_term_enrichments/1.json
  def destroy
    @go_term_enrichment = GoTermEnrichment.find(params[:id])
    @go_term_enrichment.destroy

    respond_to do |format|
      format.html { redirect_to go_term_enrichments_url }
      format.json { head :no_content }
    end
  end
end
