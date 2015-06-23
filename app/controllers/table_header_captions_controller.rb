class TableHeaderCaptionsController < ApplicationController
  # GET /table_header_captions
  # GET /table_header_captions.json
  def index
    @table_header_captions = TableHeaderCaption.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @table_header_captions }
    end
  end

  def get
    
    @table_header_caption =nil 
    h = {
      :table_id => params[:table_id], 
      :column_name => params[:column_name]
    }
    if params[:table_id] and params[:column_name]
      @table_header_caption = TableHeaderCaption.find(:first, :conditions => h)
    end
    if !@table_header_caption
      @table_header_caption = TableHeaderCaption.new(h)
      @table_header_caption.save
    end
    respond_to do |format|
      format.html { render layout: false}# show.html.erb                                                                                        
      format.json { render json: @table_header_caption }
    end
  end
  
  
   # GET /table_header_captions/1
  # GET /table_header_captions/1.json
  def show
    @table_header_caption = TableHeaderCaption.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @table_header_caption }
     end
  end
  
  # GET /table_header_captions/new
  # GET /table_header_captions/new.json
  def new
    @table_header_caption = TableHeaderCaption.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table_header_caption }
    end
  end

  # GET /table_header_captions/1/edit
  def edit
    @table_header_caption = TableHeaderCaption.find(params[:id])
  end

  # POST /table_header_captions
  # POST /table_header_captions.json
  def create
    @table_header_caption = TableHeaderCaption.new(params[:table_header_caption])

    respond_to do |format|
      if @table_header_caption.save
        format.html { redirect_to @table_header_caption, notice: 'Table header caption was successfully created.' }
        format.json { render json: @table_header_caption, status: :created, location: @table_header_caption }
      else
        format.html { render action: "new" }
        format.json { render json: @table_header_caption.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /table_header_captions/1
  # PUT /table_header_captions/1.json
  def update
    @table_header_caption = TableHeaderCaption.find(params[:id])

    respond_to do |format|
      if @table_header_caption.update_attributes(params[:table_header_caption])
        format.html { redirect_to @table_header_caption, notice: 'Table header caption was successfully updated.' }
     #     render :nothing => true}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @table_header_caption.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /table_header_captions/1
  # DELETE /table_header_captions/1.json
  def destroy
    @table_header_caption = TableHeaderCaption.find(params[:id])
    @table_header_caption.destroy

    respond_to do |format|
      format.html { redirect_to table_header_captions_url }
      format.json { head :no_content }
    end
  end
end
