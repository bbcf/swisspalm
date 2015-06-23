namespace :swisspalm do
  task :test, [:id] do |t, args|
    
    require "#{Rails.root}/config/environment"
    #    require 'rubygems'        # if you use RubyGems
    #    require 'daemons'
    require 'net/ftp'
    require 'uri'
    require 'json'
    require 'sqlite3'
    
    include Basic
    
    puts args.id
    
  end
end
