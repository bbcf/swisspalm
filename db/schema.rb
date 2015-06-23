# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131108194835) do

  create_table "articles", :force => true do |t|
    t.text     "title"
    t.text     "authors"
    t.integer  "year"
    t.integer  "pmid"
    t.datetime "created_at"
  end

  add_index "articles", ["pmid"], :name => "articles_pmid_id_idx"

  create_table "cell_types", :force => true do |t|
    t.text    "name"
    t.integer "cellosaurus_cell_type_id"
  end

  create_table "cellosaurus_cell_types", :force => true do |t|
    t.text    "name"
    t.text    "ac"
    t.integer "organism_id"
  end

  create_table "confidence_levels", :force => true do |t|
    t.text "name"
    t.text "tag"
  end

  create_table "data_types", :force => true do |t|
    t.text "name"
    t.text "tag"
    t.text "description"
    t.text "url_link"
    t.text "url_download"
    t.text "obj"
    t.text "id_field"
    t.text "name_field"
    t.text "query_condition"
    t.text "condition"
    t.text "description_field"
  end

  create_table "go_relations", :id => false, :force => true do |t|
    t.integer "id"
    t.integer "relationship_type_id"
    t.integer "term1_id",                            :null => false
    t.integer "term2_id",                            :null => false
    t.integer "complete",             :default => 0, :null => false
  end

  add_index "go_relations", ["term2_id"], :name => "go_relations_term2_id_idx"

  create_table "go_terms", :id => false, :force => true do |t|
    t.integer "id",                                                :null => false
    t.string  "name",                           :default => "",    :null => false
    t.string  "term_type",        :limit => 55,                    :null => false
    t.string  "acc",                                               :null => false
    t.integer "is_obsolete",                    :default => 0,     :null => false
    t.integer "is_root",                        :default => 0,     :null => false
    t.integer "is_relation",                    :default => 0,     :null => false
    t.boolean "in_swisspalm"
    t.boolean "has_palm_protein",               :default => false
  end

  create_table "history_sites", :force => true do |t|
    t.integer  "site_id"
    t.integer  "pos"
    t.integer  "hit_id"
    t.integer  "organism_id"
    t.integer  "cell_type_id"
    t.integer  "subcellular_fraction_id"
    t.boolean  "required_mod",            :default => false
    t.boolean  "in_uniprot",              :default => false
    t.datetime "created_at"
    t.integer  "curator_id"
    t.integer  "validator_id"
    t.integer  "user_id"
    t.text     "technique_ids"
    t.text     "reaction_ids"
    t.boolean  "uncertain_pos",           :default => false
  end

  create_table "history_studies", :force => true do |t|
    t.integer  "study_id"
    t.text     "authors"
    t.integer  "year"
    t.integer  "pmid"
    t.integer  "organism_id"
    t.integer  "cell_type_id"
    t.integer  "subcellular_fraction_id"
    t.boolean  "large_scale",             :default => true
    t.boolean  "hidden",                  :default => false
    t.integer  "user_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.text     "technique_ids"
  end

  create_table "hit_lists", :force => true do |t|
    t.integer "study_id"
    t.integer "confidence_level_id", :limit => 2
    t.text    "label"
  end

  create_table "hit_sites", :force => true do |t|
    t.integer "pos"
    t.integer "hit_id"
    t.integer "transferase"
    t.boolean "required_mod"
  end

  create_table "hit_values", :force => true do |t|
    t.integer "hit_id"
    t.integer "value_type_id"
    t.text    "value"
  end

  create_table "hits", :force => true do |t|
    t.integer  "protein_id"
    t.integer  "isoform_id"
    t.integer  "study_id"
    t.integer  "hit_list_id"
    t.integer  "curator_id"
    t.integer  "validator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hits_techniques", :id => false, :force => true do |t|
    t.integer "hit_id"
    t.integer "technique_id"
  end

  create_table "ipi_proteins", :force => true do |t|
    t.text    "ipi_id"
    t.integer "protein_id"
  end

  create_table "isoforms", :force => true do |t|
    t.integer "protein_id"
    t.integer "isoform"
    t.boolean "main",        :default => false
    t.text    "seq"
    t.text    "refseq_id"
    t.text    "iso_ma_mask"
  end

  add_index "isoforms", ["protein_id"], :name => "isoforms_protein_id_idx"

  create_table "organisms", :force => true do |t|
    t.text    "name"
    t.text    "up_tag"
    t.integer "taxid"
    t.text    "go_url_part"
  end

  create_table "predictions", :force => true do |t|
    t.integer "isoform_id"
    t.integer "pos"
    t.string  "cp_cluster",       :limit => 1
    t.float   "cp_score"
    t.float   "cp_high_cutoff"
    t.float   "cp_medium_cutoff"
    t.float   "cp_low_cutoff"
    t.float   "cp_all_cutoff"
  end

  create_table "protein_go_associations", :force => true do |t|
    t.integer "protein_id"
    t.integer "go_term_id"
    t.boolean "parent"
  end

  add_index "protein_go_associations", ["protein_id", "go_term_id"], :name => "protein_go_associations_gene_id_go_term_id_idx"

  create_table "protein_links", :force => true do |t|
    t.integer "source_type_id"
    t.text    "value"
    t.integer "protein_id"
  end

  add_index "protein_links", ["value"], :name => "protein_links_value_idx"

  create_table "proteins", :force => true do |t|
    t.text     "up_ac"
    t.text     "up_id"
    t.text     "description"
    t.integer  "organism_id"
    t.boolean  "has_hits",         :default => false
    t.boolean  "trembl",           :default => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nber_studies"
    t.integer  "nber_all_studies"
  end

  add_index "proteins", ["up_ac"], :name => "proteins_up_ac_idx"
  add_index "proteins", ["up_id"], :name => "proteins_up_id_idx"

  create_table "protocols", :force => true do |t|
    t.text     "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",     :default => false
  end

  create_table "reactions", :force => true do |t|
    t.integer  "site_id"
    t.integer  "protein_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "curator_id"
    t.integer  "validator_id"
  end

  create_table "ref_isoforms", :force => true do |t|
    t.integer "source_type_id"
    t.text    "value"
    t.integer "isoform_id"
  end

  add_index "ref_isoforms", ["value"], :name => "ref_isoforms_value_idx"

  create_table "ref_palms", :force => true do |t|
    t.integer "source_type_id"
    t.text    "value"
    t.integer "protein_id"
  end

  add_index "ref_palms", ["value"], :name => "ref_palm_value_idx"

  create_table "ref_proteins", :force => true do |t|
    t.integer "source_type_id"
    t.text    "value"
    t.integer "protein_id"
  end

  add_index "ref_proteins", ["value"], :name => "ref_proteins_value_idx"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.integer  "pos"
    t.integer  "hit_id"
    t.integer  "organism_id"
    t.integer  "cell_type_id"
    t.integer  "subcellular_fraction_id"
    t.boolean  "required_mod",            :default => false
    t.boolean  "in_uniprot",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "curator_id"
    t.integer  "validator_id"
    t.integer  "user_id"
    t.boolean  "uncertain_pos",           :default => false
  end

  create_table "sites_techniques", :id => false, :force => true do |t|
    t.integer "site_id"
    t.integer "technique_id"
  end

  create_table "source_types", :force => true do |t|
    t.text "name"
    t.text "description"
  end

  create_table "states", :force => true do |t|
    t.text "name"
    t.text "description"
  end

  create_table "studies", :force => true do |t|
    t.text     "authors"
    t.integer  "year"
    t.integer  "pmid"
    t.integer  "organism_id"
    t.integer  "cell_type_id"
    t.integer  "subcellular_fraction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.boolean  "large_scale",             :default => true
    t.boolean  "hidden",                  :default => false
    t.integer  "user_id"
    t.integer  "parent_id"
  end

  create_table "studies_techniques", :id => false, :force => true do |t|
    t.integer "study_id"
    t.integer "technique_id"
  end

  create_table "subcellular_fractions", :force => true do |t|
    t.text "name"
  end

  create_table "techniques", :force => true do |t|
    t.text    "name"
    t.boolean "large_scale"
    t.boolean "site_characterization", :default => false
    t.integer "parent_id"
  end

  create_table "tmp_words", :force => true do |t|
    t.text    "value"
    t.text    "protein_ids"
    t.boolean "has_hits"
  end

  add_index "tmp_words", ["value"], :name => "tmp_words_value_idx"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",                  :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.text     "name"
    t.string   "initials",               :limit => 8
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "value_types", :force => true do |t|
    t.text "name"
  end

  create_table "verb_types", :force => true do |t|
    t.text "name"
    t.text "description"
  end

  create_table "verbs", :force => true do |t|
    t.text    "name"
    t.text    "description"
    t.text    "obj1_data_types"
    t.text    "obj2_data_types"
    t.integer "verb_type_id"
  end

  create_table "vocabs", :force => true do |t|
    t.text    "name"
    t.text    "description"
    t.integer "data_type_id"
  end

  create_table "words", :force => true do |t|
    t.text    "value"
    t.text    "protein_ids"
    t.boolean "has_hits"
  end

  add_index "words", ["value"], :name => "words_value_idx"

end
