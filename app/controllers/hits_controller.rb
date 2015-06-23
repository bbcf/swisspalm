class HitsController < ApplicationController

  # GET /hits
  # GET /hits.json
  def index
    # @hits = Hit.all
     #    @studies = Study.all.select{|e| e.large_scale == false}.sort{|a, b| a.id <=> b.id}
    @hits = Hit.find(:all, :joins => "join studies on (studies.id = hits.study_id)", :conditions =>  {:studies =>  {:large_scale => false}})
    @hits.reject!{|h| h.study.hidden == true} if !admin? and !lab_user?
    @protein_count1 = @hits.map{|h| h.protein_id}.uniq.size
    @protein_count2 = @hits.select{|h| h.sites.size!=0}.map{|h| h.protein_id}.uniq.size
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hits }
    end
  end

  # GET /hits/1
  # GET /hits/1.json
  def show
    @hit = Hit.find(params[:id])
    if @hit.study.hidden == false or (admin? or lab_user?)
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @hit }
      end
    else
      render :nothing => true
    end
  end

  # GET /hits/new
  # GET /hits/new.json
  def new
    @hit = Hit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hit }
    end
  end

  # GET /hits/1/edit
  def edit
    @hit = Hit.find(params[:id])
  end

  # POST /hits
  # POST /hits.json
  def create
    @hit = Hit.new(params[:hit])

    respond_to do |format|
      if @hit.save
        format.html { redirect_to @hit, notice: 'Hit was successfully created.' }
        format.json { render json: @hit, status: :created, location: @hit }
      else
        format.html { render action: "new" }
        format.json { render json: @hit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hits/1
  # PUT /hits/1.json
  def update
    @hit = Hit.find(params[:id])

    respond_to do |format|
      if @hit.update_attributes(params[:hit])
        format.html { redirect_to @hit, notice: 'Hit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hits/1
  # DELETE /hits/1.json
  def destroy
    @hit = Hit.find(params[:id])
    @hit.reactions.destroy_all
    @hit.destroy

    respond_to do |format|
      format.html { redirect_to hits_url }
      format.json { head :no_content }
    end
  end
end
