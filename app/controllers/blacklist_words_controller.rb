class BlacklistWordsController < ApplicationController
  # GET /blacklist_words
  # GET /blacklist_words.json
  def index
    @blacklist_words = BlacklistWord.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @blacklist_words }
    end
  end

  # GET /blacklist_words/1
  # GET /blacklist_words/1.json
  def show
    @blacklist_word = BlacklistWord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @blacklist_word }
    end
  end

  # GET /blacklist_words/new
  # GET /blacklist_words/new.json
  def new
    @blacklist_word = BlacklistWord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blacklist_word }
    end
  end

  # GET /blacklist_words/1/edit
  def edit
    @blacklist_word = BlacklistWord.find(params[:id])
  end

  # POST /blacklist_words
  # POST /blacklist_words.json
  def create
    @blacklist_word = BlacklistWord.new(params[:blacklist_word])

    respond_to do |format|
      if @blacklist_word.save
        format.html { redirect_to @blacklist_word, notice: 'Blacklist word was successfully created.' }
        format.json { render json: @blacklist_word, status: :created, location: @blacklist_word }
      else
        format.html { render action: "new" }
        format.json { render json: @blacklist_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /blacklist_words/1
  # PUT /blacklist_words/1.json
  def update
    @blacklist_word = BlacklistWord.find(params[:id])

    respond_to do |format|
      if @blacklist_word.update_attributes(params[:blacklist_word])
        format.html { redirect_to @blacklist_word, notice: 'Blacklist word was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @blacklist_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blacklist_words/1
  # DELETE /blacklist_words/1.json
  def destroy
    @blacklist_word = BlacklistWord.find(params[:id])
    @blacklist_word.destroy

    respond_to do |format|
      format.html { redirect_to blacklist_words_url }
      format.json { head :no_content }
    end
  end
end
