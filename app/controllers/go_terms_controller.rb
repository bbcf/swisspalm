class GoTermsController < ApplicationController
  # GET /go_terms
  # GET /go_terms.json
  def index
    @go_terms = GoTerm.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @go_terms }
    end
  end

  # GET /go_terms/1
  # GET /go_terms/1.json
  def show
    @go_term = GoTerm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @go_term }
    end
  end

  # GET /go_terms/new
  # GET /go_terms/new.json
  def new
    @go_term = GoTerm.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @go_term }
    end
  end

  # GET /go_terms/1/edit
  def edit
    @go_term = GoTerm.find(params[:id])
  end

  # POST /go_terms
  # POST /go_terms.json
  def create
    @go_term = GoTerm.new(params[:go_term])

    respond_to do |format|
      if @go_term.save
        format.html { redirect_to @go_term, notice: 'Go term was successfully created.' }
        format.json { render json: @go_term, status: :created, location: @go_term }
      else
        format.html { render action: "new" }
        format.json { render json: @go_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /go_terms/1
  # PUT /go_terms/1.json
  def update
    @go_term = GoTerm.find(params[:id])

    respond_to do |format|
      if @go_term.update_attributes(params[:go_term])
        format.html { redirect_to @go_term, notice: 'Go term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @go_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /go_terms/1
  # DELETE /go_terms/1.json
  def destroy
    @go_term = GoTerm.find(params[:id])
    @go_term.destroy

    respond_to do |format|
      format.html { redirect_to go_terms_url }
      format.json { head :no_content }
    end
  end
end
