namespace :swisspalm do
  
  desc "Create words"
  task :create_words, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    h_words = {}
    
#    #### delete obsolete words
#    puts "Deleting obsolete words..."
#    h_proteins = {}
#    proteins = Protein.find(:all, :conditions => {:has_hits => true})
#    proteins.each do |p|
#      h_proteins[p.id]=1
#    end
#    TmpWord.all.each do |word|
#      protein_list = word.protein_ids.split(',')
#      new_protein_list = []
#      protein_list.each do |e|
#        new_protein_list.push(e) if h_proteins[e.to_i]
#      end
#      new_protein_ids = new_protein_list.join(',')
#      if new_protein_ids != word.protein_ids
#        if new_protein_ids != ''
#          puts "Update " + word.value
#          word.update_attribute(:protein_ids, new_protein_ids)
#        else
#          puts "Destroy #{word.value}."
#          word.destroy
#        end
#      end
#      # `psql -c 'delete from words where protein_id in (select id from proteins where has_hits = false)' swisspalm`
#    end


    `psql -c 'drop table tmp_words' swisspalm`
    `psql -c 'create table tmp_words(id serial, value text, protein_ids text, has_hits bool, primary key (id))' swisspalm`
    `psql -c 'create index tmp_words_value_idx on tmp_words (value)' swisspalm`

    puts "Updating words..."
    Protein.all.each do |protein|
      
      group_words =  protein.description.split(/[\[\]\(\),;\:]+/).map{|e| e.split(/[\s]+/, -1).select{|e2| e2 != ''}}.select{|e| e.size > 0}
      
      list = [protein.up_ac, protein.up_id] + protein.ref_proteins.select{|e| e.source_type and e.source_type_id <4}.map{|e| e.value}
      
      group_words =  protein.description.split(/[\[\]\(\),;\:]+/).map{|e| e.split(/[\s]+/, -1).select{|e2| e2 != ''}}.select{|e| e.size > 0}
      
      #### creer des suites de n words depuis la description                                                                                                               
      group_words.each do |group_word|
        list_kwords = []
        max_length = group_word.size
        ## chaque longueur d'expression                                                                                                                                    
        (1 .. max_length).to_a.each do |nber_words| #description_words.each_index do |i|                                                                                   
          (0 .. max_length-nber_words).to_a.each do |start|
            list_kwords.push((start .. start+nber_words).to_a.map{|i| group_word[i]}.join(" "))
          end
        end
        list+=list_kwords
      end
      
      list.each do |e|
        h ={:value => e.chomp("\s")}
        word = TmpWord.find(:first, :conditions => h)

        if !word
          h[:protein_ids] = protein.id.to_s
          h[:has_hits] = protein.has_hits
          word = TmpWord.new(h)
          word.save
        else         
          protein_ids = word.protein_ids.split(/,/) #if word.protein_ids
          if !protein_ids.include?(protein.id.to_s)
            protein_ids.push(protein.id.to_s)
            word.update_attributes({:protein_ids => protein_ids.join(","), :has_hits => ((protein.has_hits) ? true : word.has_hits) })
          end
        end
      end
    end
    
    
    ### after creating words, we have to filter out the ones that are not interesting for the autocompletion task 
    ### i.e. the ones that are part of others and pointing to the same protein_ids
    puts "Removing not useful words..."

#    `psql -c 'create index tmp_words_protein_ids_idx on tmp_words (protein_ids)' swisspalm`
    words = TmpWord.all.sort{|a, b| b.value <=> a.value}
    h_words_by_protein_ids={}
    words.each do |word|
      h_words_by_protein_ids[word.protein_ids]||=[]
      h_words_by_protein_ids[word.protein_ids].push(word)
    end
    
    
    words.each do |word|
      if TmpWord.exists?(word.id) ### might have disappeared
        #word_length = word.value.size
        #TmpWord.find(:all, :conditions => { :protein_ids => word.protein_ids}).each do |compared_word|          
        h_words_by_protein_ids[word.protein_ids].each do |compared_word|
          if compared_word.value != word.value and word.value.include?(compared_word.value)
            compared_word.destroy
          end
        end
      end
    end

    ### switch
    `psql -c 'drop table old_words' swisspalm`
    `psql -c 'alter table words rename to old_words' swisspalm`
    `psql -c 'alter table tmp_words rename to words' swisspalm`

    ### rename index                
    `psql -c 'ALTER INDEX tmp_words_value_idx RENAME TO words_value_idx' swisspalm`

  end
  #    list_words = []
  #
  #    h_words.each_key do |word|
  #      list_words.push([word, h_words[word]])
  #    end
  #    
  #    list_words.sort!{|a, b| b[1] <=> a[1]}
  #
  #    (0 .. 1000).to_a.each do |i|
  #      puts list_words[i][0] + "=>" +  list_words[i][1].to_s 
  #    end
  #  end

  
  
end


