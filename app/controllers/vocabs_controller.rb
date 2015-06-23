class VocabsController < ApplicationController
  # GET /vocabs
  # GET /vocabs.json
  def index
    @vocabs = Vocab.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vocabs }
    end
  end

  # GET /vocabs/1
  # GET /vocabs/1.json
  def show
    @vocab = Vocab.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vocab }
    end
  end

  # GET /vocabs/new
  # GET /vocabs/new.json
  def new
    @vocab = Vocab.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vocab }
    end
  end

  # GET /vocabs/1/edit
  def edit
    @vocab = Vocab.find(params[:id])
  end

  # POST /vocabs
  # POST /vocabs.json
  def create
    @vocab = Vocab.new(params[:vocab])

    respond_to do |format|
      if @vocab.save
        format.html { redirect_to @vocab, notice: 'Vocab was successfully created.' }
        format.json { render json: @vocab, status: :created, location: @vocab }
      else
        format.html { render action: "new" }
        format.json { render json: @vocab.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /vocabs/1
  # PUT /vocabs/1.json
  def update
    @vocab = Vocab.find(params[:id])

    respond_to do |format|
      if @vocab.update_attributes(params[:vocab])
        format.html { redirect_to @vocab, notice: 'Vocab was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vocab.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vocabs/1
  # DELETE /vocabs/1.json
  def destroy
    @vocab = Vocab.find(params[:id])
    @vocab.destroy

    respond_to do |format|
      format.html { redirect_to vocabs_url }
      format.json { head :no_content }
    end
  end
end
