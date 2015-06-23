module Parse
  
  def parse_fasta(lines)
    
    h_seq={}
    ac=''
    lines.each do |l|
      if m=l.match(/^>(.+)/)
        line = m[1]
        fields = line.split("|")
        ac = fields[1]
        if h_seq[ac]
          puts "error with #{ac}"
        else
          h_seq[ac]=''
        end
      else
        h_seq[ac]+=l
      end
    end

    return h_seq
    
  end
  

end
