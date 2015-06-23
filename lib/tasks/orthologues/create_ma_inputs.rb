def read_fasta(file)

  tmp_h = {
    'ac_to_id' => {}, 
    'id_to_seq' => {}, 
    'id_to_species' => {}
  }

  File.open(file, 'r') do |f|

    all = f.readlines

    list_sequences = []

    cur_ac=''
    cur_id=''
    cur_species=''
 
    all.each do |l|
      if m = l.match(/^>.+?\|(.+?)\|([\w_]+).+?OS=(.+?) (GN|PE)/)
        cur_ac = m[1]
        cur_id = m[2]
        cur_species = m[3]
        #    puts cur_entry
      else
        tmp_h['id_to_seq'][cur_id]||=''
        tmp_h['id_to_seq'][cur_id]+=l
        tmp_h['ac_to_id'][cur_ac]=cur_id
        tmp_h['id_to_species'][cur_id]=cur_species
#        if cur_id == 'H3AQ09_LATCH'
#          puts cur_id + "!!!!"
#        end
      end
    end
    #    puts tmp_h['id_to_seq']['H3AQ09_LATCH']
    return tmp_h
    
  end
end


input_dir = 'ma_input/'

### retrieve sequences
seq_h = read_fasta("seq_all_orthologues_zdhhc.fa")
tmp_h= read_fasta("seq_all_zdhhc.fa")
seq_h.each_key do |k|
  tmp_h[k].each_key do |k2|
    seq_h[k][k2]=tmp_h[k][k2]
  end
end

#puts seq_h['id_to_seq']['F7DR35_XENTR']

#puts seq_h.keys.size

open("organisms.csv", 'r') do |f|
  
  lines = f.readlines
  
  (2 .. lines.size-1).to_a.each do |i|
    l =lines[i]
    #    puts l
    tab = l.chomp.split(',')
    human_ref_ac = tab[0]
    human_ref_id = seq_h['ac_to_id'][human_ref_ac]
    open(input_dir + human_ref_id + "_" + human_ref_ac, 'w') do |f2|
      #      f2.write(">#{human_ref_id}|Homo sapiens\n#{seq_h['id_to_seq'][human_ref_id]}")
      
      (1 .. tab.size-1).to_a.each do |j|
        tmp_id = tab[j]
        if tmp_id != 'NA'
          f2.write(">#{tmp_id}|#{seq_h['id_to_species'][tmp_id]}\n#{seq_h['id_to_seq'][tmp_id]}")
        end
      end
      
    end

  end 
end



