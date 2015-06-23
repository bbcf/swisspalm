class TmpWordsController < ApplicationController
  # GET /tmp_words
  # GET /tmp_words.json
  def index
    @tmp_words = TmpWord.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tmp_words }
    end
  end

  # GET /tmp_words/1
  # GET /tmp_words/1.json
  def show
    @tmp_word = TmpWord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tmp_word }
    end
  end

  # GET /tmp_words/new
  # GET /tmp_words/new.json
  def new
    @tmp_word = TmpWord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tmp_word }
    end
  end

  # GET /tmp_words/1/edit
  def edit
    @tmp_word = TmpWord.find(params[:id])
  end

  # POST /tmp_words
  # POST /tmp_words.json
  def create
    @tmp_word = TmpWord.new(params[:tmp_word])

    respond_to do |format|
      if @tmp_word.save
        format.html { redirect_to @tmp_word, notice: 'Tmp word was successfully created.' }
        format.json { render json: @tmp_word, status: :created, location: @tmp_word }
      else
        format.html { render action: "new" }
        format.json { render json: @tmp_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tmp_words/1
  # PUT /tmp_words/1.json
  def update
    @tmp_word = TmpWord.find(params[:id])

    respond_to do |format|
      if @tmp_word.update_attributes(params[:tmp_word])
        format.html { redirect_to @tmp_word, notice: 'Tmp word was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tmp_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tmp_words/1
  # DELETE /tmp_words/1.json
  def destroy
    @tmp_word = TmpWord.find(params[:id])
    @tmp_word.destroy

    respond_to do |format|
      format.html { redirect_to tmp_words_url }
      format.json { head :no_content }
    end
  end
end
