namespace :swisspalm do

  desc "Blacklist words"
  task :blacklist_words, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    h_words = {}

    Protein.all.each do |protein|
 
      protein.description.split(/[^\w\d]+/).map{|e| e.downcase}.each do |word|
      
        h_words[word]||=0
        h_words[word]+=1
                
      end
      
   end
	
    list_words = []

    h_words.each_key do |word|
      list_words.push([word, h_words[word]])
    end
    
    list_words.sort!{|a, b| b[1] <=> a[1]}

    (0 .. 1000).to_a.each do |i|
      puts list_words[i][0] + "=>" +  list_words[i][1].to_s 
    end
  end
 
end


