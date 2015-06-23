namespace :swisspalm do

  desc "Load orthologues (internal)"
  task :load_orthologues, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
    require 'mechanize'
    require 'hpricot'
    require 'bio'
    include LoadData

  download_dir = Pathname.new(APP_CONFIG[:data_dir]) + "downloads"
    
    puts "Get organisms..."
    h_organisms = {}
    h_all_organisms = {}
    Organism.all.map{|o| h_all_organisms[o.up_tag]=1; o}.select{|e| e.has_proteins == true}.map{|o| h_organisms[o.up_tag]=1}
    
    puts "Get proteins..."
    h_proteins = {}
    h_all_proteins={}
    Protein.all.map{|p| h_all_proteins[p.up_ac]=p.id; p}.select{|e| e.has_hits == true}.map{|e| h_proteins[e.up_ac] = e.id}
	    
  end	
end	
