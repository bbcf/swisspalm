class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :admin?, :superadmin?, :validator_user?, :lab_user?
  before_filter :init_session, :init, :menu

  def init_session
    session[:search_db]||='palm'
    session[:studies]||=[]
    session[:predictions]||=[]
    session[:organism_id]||=nil
    session[:proteins]={} if session[:proteins]==[] or session[:proteins] == nil
  end

  def init
    @all_palm_proteins_count = Protein.count(:conditions => {:has_hits => true})
    @all_proteins_count = Protein.count
  end

  def menu
    
    @h_menu = {
      :home => ['Home', root_path],
      :palmitomes => ['Palmitoyl-proteomes', studies_path({:large_scale => 1})],
#      :targeted_studies => ['Targeted studies', studies_path(:large_scale => 0)],
      :annotations => ['Curated data', hits_path()],
      :pats_and_apts => ['PATs & APTs', pat_apt_summary_path()],
      :stats => ['Stats', stats_by_organism_path()],
      :admin => ['Admin', curation_path()]
    } 
    uri = URI.encode(request.fullpath)
    @h_menu.each_key do |k|
      if uri !='/users' and uri != '/users/password' and uri != '/logout' and Rails.application.routes.recognize_path(uri) == Rails.application.routes.recognize_path(@h_menu[k][1])
     # @tmp_full_path.gsub!(/(\?.+)/, '') if !@h_menu[k][1].match(/\?/)
     # @tmp_full_path+='index' if m = @tmp_full_path.match(/\//) and m.size == 2 
     # if @tmp_full_path == @h_menu[k][1]
        session[:menu]=k
      end
    end
  end


  protected
  
  
  def superadmin?
     current_user and ['bbcf.epfl@gmail.com'].include?(current_user.email)
  end
  
  def admin?
    current_user and ['bbcf.epfl@gmail.com', 'daniel.migliozzi@epfl.ch', 'mathieu.blanc@epfl.ch'].include?(current_user.email)
  end

  def lab_user?
    current_user and ['bbcf.epfl@gmail.com', 
                      'fabrice.david@epfl.ch', 'daniel.migliozzi@epfl.ch', 'mathieu.blanc@epfl.ch', 
                      'gisou.vandergoot@epfl.ch', 'romain.hamelin@epfl.ch', 
                      'maria.zaballa@epfl.ch', 'laurence.abrami@epfl.ch', 'patrick.sandoz@epfl.ch',
                     'matteodp@gmail.com'].include?(current_user.email)
  end

  def validator_user?
    current_user and ['mathieu.blanc@epfl.ch'].include?(current_user.email)
  end
  
  def authorize
    
    authorize_signed = [
                        'cell_types', 
                        'techniques', 
                        'subcellular_fractions'
                       ]
    authorize_signed_actions = [
                                ['hit_lists', ['show']],
                                ['studies', ['index', 'show', 'del_from_session', 'add_to_session']],
                                ['organisms', ['index', 'show', 'palmitome_summary', 'go_term_summary', 'ptm_stats', 'phosphosite_stats', 'subcell_location_stats', 'cys_topo_stats', 'cys_stats', 'common_prot_in_palmitomes', 'diff_prot_in_palmitomes']],
                                ['pages', ['pat_apt_summary', 'pubmed', 'about', 'contact', 'what', 'stats_by_organism', 'palmitome_comparison', 'palmitome_stats']]
                               ]
#    authorize_lab_user_actions = [
#                                  ['pages', ['pat_apt_summary']]
#                                 ]
    
    h_authorize_signed = {}
    authorize_signed.map{|e| h_authorize_signed[e]=1}
    h_authorize_signed_actions = {}
    authorize_signed_actions.map{|e| e[1].map{|e2| h_authorize_signed_actions[e[0] + "," + e2]=1}}
#    h_authorize_lab_user_actions = {}
#    authorize_lab_user_actions.map{|e| e[1].map{|e2| h_authorize_lab_user_actions[e[0] + "," + e2]=1}}


     #flash[:notice] =  h_authorize_signed.to_yaml + "---------" + h_authorize_signed_actions.to_yaml + [controller_name, action_name].join(',')
    if (h_authorize_signed[controller_name] or !h_authorize_signed_actions[[controller_name, action_name].join(',')]) and (!lab_user? and !admin? and !superadmin?)
      flash[:notice] = "Unauthorized access, login required."
      if params[:partial]
        redirect_to root_path(:partial => 1, :format =>'js')
      else
        redirect_to root_path
      end
      false 
    end
#    elsif (h_authorize_lab_user_actions[[controller_name, action_name].join(',')]) and !lab_user? and !admin?
#      flash[:notice] = "Unauthorized access, lab user login required."
#      if params[:partial]
#        redirect_to root_path(:partial => 1, :format =>'js')
#      else
#        redirect_to root_path
#      end
#      false
#    else
#       logger.debug h_authorize_lab_user_actions[[controller_name, action_name].join(',')].to_json
#    end
  end
  
end
