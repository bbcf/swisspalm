namespace :swisspalm do
  
  desc "Count serines"
  task :count_serines, [:version] do |t, args|

    ### Use rails enviroment   

    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP      
    
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch

    counts=[]
    
    Isoform.all.each do |i|
      counts.push([i, i.seq.count('S').to_f*100/i.seq.size])
    end
    
    counts.sort!{|a, b| a[1] <=> b[1]}.reverse!
    
    puts counts.first(10).map{|e| e[0].protein.up_ac + " => " + e[1].to_s}.join("\n")
    
  end	
end
