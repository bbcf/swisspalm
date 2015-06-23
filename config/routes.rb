SwissPalm::Application.routes.draw do
  resources :topologies

  resources :table_header_captions do
    collection do
      get :get
    end
  end
  
  resources :protein_complexes

  resources :technique_categories

  resources :interpros

  resources :uniprot_statuses

  resources :isoform_diff_predictions

  resources :phosphosite_types

  resources :phosphosite_features

  resources :diseases

  resources :subcellular_locations

  resources :organism_topology_stats

  resources :interpro_matches

  resources :technique_classes

  resources :feature_types

  resources :features

  resources :variants

  resources :tmp_palmitome_entries

  resources :palmitome_entries

  resources :hit_protein_groups

  resources :orthologues

  resources :ortho_sources

  resources :orthodb_best_orthologues

  resources :orthodb_levels

  resources :orthodb_attrs

  resources :pat_isoforms

  resources :cysteines

  resources :homologues

  resources :oma_pairs

  resources :oma_relation_types

  resources :protein_group_values

  resources :protein_groups

  resources :file_types

  resources :go_term_enrichments

  resources :distances

  resources :cys_envs do 
    collection do
      get :compare
    end
  end

  resources :tmp_words

  resources :predictions

  resources :articles

  resources :history_sites

  resources :history_studies

  resources :annots

  resources :vocabs

  resources :verbs

  resources :verb_types

  resources :states

  resources :data_types

  resources :reactions

  resources :sites do
    collection do 
      get :meta_edit
      get :upd_form
      get :index_by_hit
    end
 end

  resources :hit_sites

  resources :ref_isoforms

  resources :protein_go_associations

  resources :go_relations

  resources :go_terms

  resources :ref_palms

  resources :words

  resources :blacklist_words

  resources :cellosaurus_cell_types

  resources :protocols

  resources :pages do 
    get :browse
    get :contact
    get :about
    get :pubmed
#    get :prediction
    get :what
    get :pat_apt_summary
    get :pat_apt_graph
    get :palmitome_comparison
    get :site_composition

    get :env_dataset_form
    post :compute_env_dataset
    get :background_composition
  end


  resources :ref_proteins

  resources :source_types

  resources :value_types

  resources :hit_values

  resources :gene_names

  resources :isoforms

  devise_for :users

  resources :hits

  resources :hit_lists do
    collection do 
      get :evaluate
    end
  end


  resources :confidence_levels

  resources :proteins do
    get :autocomplete_ref_palm_value, :on => :collection
    collection do
      get :change_db
      get :search
      post :download
      post :batch_search
      get :autocomplete
      get :autocomplete2
    end
    member do
      get :view_ali
      get :view_ali_ortho
      get :upd_cart
    end
  end

  resources :studies do
    resources :hit_lists do       
    end
    get :new_large_scale
    collection do 
      get :autocomplete
      get :load_article
    end
    member do
      get :add_to_session
      get :del_from_session
    end
  end

  resources :subcellular_fractions

  resources :cell_types

  resources :organisms do
    collection do 
      get :cys_stats
      get :prot_stats
      get :cys_topo_stats
      get :subcell_location_stats
      get :uniprot_domain_stats
      get :ptm_stats      
      get :phosphosite_stats
      get :protein_complex_stats
      get :common_prot_in_palmitomes
      get :diff_prot_in_palmitomes
    end
    member do
      get :palmitome_comparison
      get :go_term_summary
    end
  end

  resources :techniques

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  devise_scope :user do
    get "login", :to => "devise/sessions#new"
    delete "logout", :to => "devise/sessions#destroy"
    get "signup", :to => "devise/registrations#new"
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  match '/browse' => 'pages#browse'
  match '/contact' => 'pages#contact'
  match '/about' => 'pages#about'
  match '/admin' => 'pages#admin'
  match '/cys_stats_by_organism' => 'pages#cys_stats_by_organism'
  match '/stats_by_organism' => 'pages#stats_by_organism'
  match '/env_dataset_form' => 'pages#env_dataset_form'
  
 #match '/prediction' => 'pages#prediction'
  match '/pubmed' => 'pages#pubmed'
  match '/what' => 'pages#what'
  match '/curation' => 'pages#curation'
  match '/pat_apt_summary' => 'pages#pat_apt_summary'
  match '/pat_graph' => 'pages#pat_graph'
  match '/pat_by_homology_group' => 'pages#pat_by_homology_group'
  match '/pat_phylip_nj_tree' => 'pages#pat_phylip_nj_tree'
  match '/palmitome_comparison' => 'pages#palmitome_comparison'
  match '/palmitome_comparison_old' => 'pages#palmitome_comparison_old'
  match '/palmitome_stats' =>'pages#palmitome_stats'
  match '/palmitome_set_comparison_stats' =>'pages#palmitome_set_comparison_stats'
  match '/site_composition' =>'pages#site_composition'
  match '/background_composition' => 'pages#background_composition'
  match '/list_annotated_proteins' =>'pages#list_annotated_proteins'
  


   root :to => "proteins#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
