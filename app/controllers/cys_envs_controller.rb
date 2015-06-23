class CysEnvsController < ApplicationController


  def compare

    session[:predictions]||=[]

    @pos_ali = {}
    @h_proteins = {}
    @h_data={}

    Protein.find(session[:proteins].keys).each do |p|
      @h_proteins[p.id]=p
      
      ## read multiple ali                                                                                                                                                                                                            
      isoforms = p.isoforms.select{|i| i.latest_version}
      
      h_pos_ali = {}
      pos_ali = []
      h_pred = {}
      main_iso = ''
      isoforms.each do |isoform|
        iso = isoform.isoform
        
        main_iso = iso if isoform.main == true
        
        h_pred[iso]={}
        h_pos_ali[iso]={}
        
        isoform.predictions.each do |pred|
          
          ##compute position in ali                                                                                                                                                                                                     
          pos = 0
          cur_pos = 0
          gaps=0
          if isoform.iso_ma_mask
            isoform.iso_ma_mask.split(',').each do |mask_el|
              if mask_el[0] == ':'
                cur_pos += mask_el[1..-1].to_i
              else
                gaps+= mask_el[1..-1].to_i
              end
              if cur_pos > pred.pos
                pos = pred.pos + gaps
                break
              end
            end
          else
            pos = pred.pos
          end
          h_pos_ali[iso][pos]=pred.pos
          pos_ali.push(pos) if !pos_ali.include?(pos)
          h_pred[iso][pred.pos]=[
                                 pred,
                                 (pred.cp_high_cutoff > 0) ? 'hc' :
                                 ((pred.cp_medium_cutoff > 0) ? 'mc' :
                                  ((pred.cp_low_cutoff > 0) ? 'lc' : ''))
                                ]
        end
        
      end
      
      @h_data[p.id]={
        :h_pos_ali => h_pos_ali,# = {}
        :pos_ali => pos_ali,# = []
        :h_pred => h_pred,# = {}
        :main_iso => main_iso} # = ''
      
    end
  end

  # GET /cys_envs
  # GET /cys_envs.json
  def index
    @cys_envs = CysEnv.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cys_envs }
    end
  end

  # GET /cys_envs/1
  # GET /cys_envs/1.json
  def show
    @cys_env = CysEnv.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cys_env }
    end
  end

  # GET /cys_envs/new
  # GET /cys_envs/new.json
  def new
    @cys_env = CysEnv.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cys_env }
    end
  end

  # GET /cys_envs/1/edit
  def edit
    @cys_env = CysEnv.find(params[:id])
  end

  # POST /cys_envs
  # POST /cys_envs.json
  def create
    @cys_env = CysEnv.new(params[:cys_env])

    respond_to do |format|
      if @cys_env.save
        format.html { redirect_to @cys_env, notice: 'Cys env was successfully created.' }
        format.json { render json: @cys_env, status: :created, location: @cys_env }
      else
        format.html { render action: "new" }
        format.json { render json: @cys_env.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cys_envs/1
  # PUT /cys_envs/1.json
  def update
    @cys_env = CysEnv.find(params[:id])

    respond_to do |format|
      if @cys_env.update_attributes(params[:cys_env])
        format.html { redirect_to @cys_env, notice: 'Cys env was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cys_env.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cys_envs/1
  # DELETE /cys_envs/1.json
  def destroy
    @cys_env = CysEnv.find(params[:id])
    @cys_env.destroy

    respond_to do |format|
      format.html { redirect_to cys_envs_url }
      format.json { head :no_content }
    end
  end
end
