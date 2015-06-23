class IsoformsController < ApplicationController
  # GET /isoforms
  # GET /isoforms.json
  def index    
    @isoforms = Isoform.all

    respond_to do |format|
      format.html # index.html.erb
      format.text {
        require 'bio'
        fasta = ''
#        @isoforms.map{ |isoform|
#          seq = Bio::Sequence::NA.new(isoform.seq)
#          protein = isoform.protein
#          fasta+=seq.to_fasta((isoform.main == false) ? (protein.up_ac + "-" + isoform.isoform.to_s) : protein.up_ac)
#        }
        render text: fasta
      }
      format.json { render json: @isoforms }
    end
  end

  # GET /isoforms/1
  # GET /isoforms/1.json
  def show
    @isoform = Isoform.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @isoform }
    end
  end

  # GET /isoforms/new
  # GET /isoforms/new.json
  def new
    @isoform = Isoform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @isoform }
    end
  end

  # GET /isoforms/1/edit
  def edit
    @isoform = Isoform.find(params[:id])
  end

  # POST /isoforms
  # POST /isoforms.json
  def create
    @isoform = Isoform.new(params[:isoform])

    respond_to do |format|
      if @isoform.save
        format.html { redirect_to @isoform, notice: 'Isoform was successfully created.' }
        format.json { render json: @isoform, status: :created, location: @isoform }
      else
        format.html { render action: "new" }
        format.json { render json: @isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /isoforms/1
  # PUT /isoforms/1.json
  def update
    @isoform = Isoform.find(params[:id])

    respond_to do |format|
      if @isoform.update_attributes(params[:isoform])
        format.html { redirect_to @isoform, notice: 'Isoform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @isoform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /isoforms/1
  # DELETE /isoforms/1.json
  def destroy
    @isoform = Isoform.find(params[:id])
    @isoform.destroy

    respond_to do |format|
      format.html { redirect_to isoforms_url }
      format.json { head :no_content }
    end
  end
end
