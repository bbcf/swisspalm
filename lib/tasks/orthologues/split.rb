File.open('seq_all_zdhhc.fa', 'r') do |f|
  
  all = f.readlines 
  
  list_sequences = []
  
  cur_entry= ''
  tmp_h = {}
  
  all.each do |l|
    if l.match(/^>/)
      puts l
      cur_entry = l
    else
      tmp_h[cur_entry]||=''
      tmp_h[cur_entry]+=l
    end
  end
  
  tmp_h.each_key do |k|
    puts k
    if ac = k.match(/^>sp\|(\w+)/)
      f2 = 'sequences/' + ac[1]
      File.open(f2, 'w') do |f2|
        f2.write(k)
        f2.write(tmp_h[k])
      end  
    end
  end
  
end
