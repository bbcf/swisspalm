 class HitListsController < ApplicationController
   
   before_filter :authorize, :set_study
   
   require 'csv'
   require 'mechanize'
 
   include LoadData
#   include ActionView::Helpers::UrlHelper

   def set_study
     
     if params[:study_id]
       @study = Study.find(params[:study_id])
     elsif params[:id]
       @study = HitList.find(params[:id]).study
     end
   end
   
   # GET /hit_lists
   # GET /hit_lists.json
   def index
     @hit_lists = HitList.all
     
     respond_to do |format|
       format.html # index.html.erb
       format.json { render json: @hit_lists }
     end
   end
   
   # GET /hit_lists/1
   # GET /hit_lists/1.json
   def show

     helper = ApplicationController.helpers

     @hit_list = HitList.find(params[:id]) 
     
     if @hit_list.study.hidden == false or (admin? or lab_user?)
       hits = @hit_list.hits
       first_hit = @hit_list.hits.first
       protein_groups = @hit_list.protein_groups
       first_protein_group = (protein_groups) ? protein_groups.first : nil
       
       ### define headers
       headers = ['Hit_ID', 'UniProt AC', 'UniProt ID', 'Isoform', 'Gene names']
       hit_values = first_hit.hit_values.sort{|a, b| a.id <=> b.id}
       hit_values.each do |hv|
         headers.push(hv.value_type.name)
       end
       
       #       list_protein_group_values = []
       
       if first_protein_group
         #         list_protein_group_values = first_protein_group.protein_group_values.sort{|a, b| a.value_type <=> b.value_type}.select{|e| e.value_type and e.value_type.display_by_default}
         headers.push('Protein group ID', 'Identification case')
         first_protein_group.protein_group_values.sort{|a, b| a.value_type <=> b.value_type}.select{|e| e.value_type and e.value_type.display_by_default}.each do |protein_group_value|
           headers.push((protein_group_value.value_type) ? protein_group_value.value_type.name : 'NA')
         end
       end
       headers.push('Protein also found in # palmitome studies', 'Protein also found in # targeted studies')
       
       ### setup data
       @data = []
       
       h_proteins = {}
       Protein.find(hits.map{|e| e.protein_id}).each do |p|
         h_proteins[p.id]=p
       end
       h_isoforms = {}
       Isoform.find(hits.map{|e| e.isoform_id}.compact).each do |p|
         h_isoforms[p.id]=p
       end

       h_gene_names={}
       RefProtein.find(:all, 
                       :joins => 'join source_types on (source_types.id = ref_proteins.source_type_id)', 
                       :conditions => {
                         :source_types => {:name => 'gene_name'}, 
                         :protein_id => hits.map{|e| e.protein_id}}).each do |rp|
         h_gene_names[rp.protein_id]||=[]
         h_gene_names[rp.protein_id].push(rp)
       end
       
       @data.push(headers)
       hits.each do |hit|
         protein = h_proteins[hit.protein_id]
         isoform = h_isoforms[hit.isoform_id]
         gene_names =  (h_gene_names[hit.protein_id]) ? h_gene_names[hit.protein_id].map{|e| e.value}.join(", ") : 'NA' 
         #protein.ref_proteins.select{|e|
         #   e.source_type and e.source_type.name == 'gene_name'
         # }.map{|e| e.value}.join(", ")
         base_v = []
         if !params[:format] or params[:format] == 'html'
           base_v = ["SPalmH#{hit.id}", 
                helper.link_to(protein.up_ac, protein_path(protein.id)),  
                helper.link_to(protein.up_id, protein_path(protein.id)),
                (isoform) ? isoform.isoform : 'NA', 
                gene_names]
         else
           base_v = ["SPalmH#{hit.id}", protein.up_ac, protein.up_id, gene_names]
         end
         hit.hit_values.sort{|a, b| a.id <=> b.id}.each do |hv|
           base_v.push(hv.value)
         end
         
         base_v2 = []
         other_hits = protein.hits.select{|e| e.study_id != @hit_list.study_id}
         other_hits_palmitome = other_hits.select{|e| e.study.large_scale == true}
         other_hits_targeted = other_hits.select{|e| e.study.large_scale == false}
         base_v2.push(other_hits_palmitome.map{|h| h.study_id}.uniq.size)
         base_v2.push(other_hits_targeted.map{|h| h.study_id}.uniq.size)

         if hit.hit_protein_groups.size > 0
          
           hit.hit_protein_groups.each do |hit_protein_group|
             v = base_v.dup
             protein_group = hit_protein_group.protein_group
             v+=[protein_group.protein_group_id, hit_protein_group.identification_case]
             protein_group.protein_group_values.sort{|a, b| a.value_type <=> b.value_type}.select{|e| e.value_type and e.value_type.display_by_default}.each do |protein_group_value|
               if protein_group_value.value_type.name.match(/\?$/)
                 v.push((protein_group_value.value == 'true') ? 'Yes' : 'No')
               else
                 v.push(protein_group_value.value)
               end 
             end 
             v+=base_v2.dup
             @data.push(v)
           end
         else
           v = base_v.dup + base_v2.dup
           @data.push(v)
         end
         
 
       end
       
       respond_to do |format|
         format.html # show.html.erb
         format.json { render json: @data }
         format.text { render text: @data.map{|e| e.join("\t")}.join("\n") }
       end
     else
       render :nothing => true
     end
   end
   
   # GET /hit_lists/new
   # GET /hit_lists/new.json
   def new
     @hit_list = HitList.new
     
     respond_to do |format|
       format.html # new.html.erb
       format.json { render json: @hit_list }
     end
   end
   
   # GET /hit_lists/1/edit
   def edit
     @hit_list = HitList.find(params[:id])
   end
   
  # POST /hit_lists
  # POST /hit_lists.json
  def create
    params[:hit_list][:study_id]=params[:study_id]
    @hit_list = HitList.new(params[:hit_list])

    hit_lists_dir = Pathname.new(APP_CONFIG[:data_dir]) +  'uploads' + 'hit_lists'
     
    if !params[:organism_id]
      @hit_list.filename = params[:hit_list][:file].original_filename
      @hit_list.status_id = 1
      @hit_list.save     
      file = File.open((hit_lists_dir + (@hit_list.id.to_s + ".txt")), 'w')
      file.write(params[:hit_list][:file].read)
      file.close

      respond_to do |format|
        @notice = "Hit list was successfully created."
        # #{@count_found} found / #{@count_already_present} existing; #{@debug}"
        #        @notice+= " WARNING: #{@count_not_found.size} not found: #{@count_not_found.join(', ')}" if @count_not_found.size > 0
        
        format.html {
          redirect_to study_path(@study), notice: @notice
        }
      end
      
    else
      
      organism_id = (@study) ? @study.organism_id : params[:organism_id]
      study_id = (@study) ? @study.id : nil
      read_data_file(params[:hit_list][:file].read.split(/[\n\r]+/), params[:hit_list][:identifier_type], organism_id, study_id)
      
      respond_to do |format|
        
        @notice = "Hit list was successfully created. #{@count_found} found / #{@count_already_present} existing; #{@debug}"
        @notice+= " WARNING: #{@count_not_found.size} not found: #{@count_not_found.join(', ')}" if @count_not_found.size > 0
        format.html
      end

    end
    
    
    #   respond_to do |format|
 #     
    #     @notice = "Hit list was successfully created. #{@count_found} found / #{@count_already_present} existing; #{@debug}"
    #     @notice+= " WARNING: #{@count_not_found.size} not found: #{@count_not_found.join(', ')}" if @count_not_found.size > 0 
    #     
    #     format.html { 
    #       if !params[:organism_id]
    #         redirect_to study_path(@study), notice: @notice  
    #       end
    #     }
    # end
    
  end
  
  # PUT /hit_lists/1
  # PUT /hit_lists/1.json
  def update
    @hit_list = HitList.find(params[:id])

    @hits=[]

#    load_file()
    organism_id = (@study) ? @study.organism_id : params[:organism_id]
    study_id = (@study) ? @study.id : nil
    
    load_file(params[:hit_list][:file].read, params[:hit_list][:identifier_type], organism_id, study_id)

    respond_to do |format|

      @notice = "Hit list was successfully updated. #{@count_found.size} found / #{@count_already_present.size} existing; #{@debug}"
      @notice+= " WARNING: #{@count_not_found.size} not found: #{@count_not_found.join(', ')}" if @count_not_found.size > 0
      @notice+=" WARNING: existing: #{@count_already_present.join(',')}"
      #notice+=" WARNING: #{@hits.to_json}"

      @new_hits.each do |hit|
        @hit_list.hits << Hit.new(hit) 
      end
    
#      if @hit_list.update_attributes(params[:hit_list])
      format.html {}# redirect_to @hit_list, notice: notice, hits:  @hits.to_json }
        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @hit_list.errors, status: :unprocessable_entity }
#      end
    end
  end

  def evaluate
    @hit_list = HitList.new    
  end


  # DELETE /hit_lists/1
  # DELETE /hit_lists/1.json
  def destroy
    @hit_list = HitList.find(params[:id])
    @hit_list.destroy

    respond_to do |format|
       format.html { redirect_to hit_lists_url }
      format.json { head :no_content }
    end
  end
end
