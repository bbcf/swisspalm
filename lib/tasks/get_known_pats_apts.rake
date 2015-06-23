namespace :swisspalm do

  desc "Get known pats and apts"
  task :get_known_pats_apts, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include LoadData

    list_proteins = load_all_proteins("go%3a\"protein-cysteine+S-palmitoyltransferase+activity+[0019706]\"", nil, true)
    
    list_proteins.each do |protein|
      protein.update_attribute(:is_a_pat, true)
    end

  end
end
