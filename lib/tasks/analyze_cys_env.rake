namespace :swisspalm do

  desc "Analyze cystein environment"
  task :analyze_cys_env, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

    h_cys_env = {}
    window = 5

#    h_sites = {}

    list_cys = []

    puts "Loading data..."

#    Site.all.each do |site|
 #   #  h_sites[site.isoform.id][site.pos]=1
 #     isoform = site.hit.isoform || site.hit.protein.isoforms.select{|i| i.main == true}.first
  #    list_cys.push([isoform, pos])
  #  end

  #  Prediction.find(:all, :conditions => ['cp_high_cutoff is not null']).each do |cys|
  #    list_cys.push([cys.isoform, cys.pos])
  #  end


 #   list_cys.each do |isoform, pos|
 #     start_pos = pos - window   
 #     start_seq = ( start_pos < 1) ? "X" * -(start_pos-1) : ''
 #     end_pos = pos + window             
 #     end_seq = (end_pos > isoform.seq.size) ? "X" * (end_pos-isoform.seq.size) : ''
 #     start_pos = 1 if start_pos < 1                                                                                                                                          
 #     end_pos = isoform.seq.size if end_pos > isoform.seq.size
 #     cys_env = start_seq + isoform.seq[start_pos-1 .. end_pos-1] + end_seq                                                                                                                       
 #     puts "#{start_pos} -> #{end_pos} : #{cys_env}"
#
#      h_cys_env[cys_env]||=[]                                                                                                                                                  
#      h_cys_env[cys_env].push([isoform, pos])     
#    end
#

    def init_comp()
      l = ['A','C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Y','Z', 'X' ] 
      h={}
      l.map{|e| h[e]=0}
      return h
    end


    puts 'Computing alignments...'
    
    factory = Bio::ClustalW.new

    last_distance = Distance.find(:first, :order => 'cys_env_id1 desc')
    starting_x = (last_distance) ? last_distance.cys_env_id1 : 0
	
    cys_envs = CysEnv.all 
    (starting_x .. cys_envs.size-1).each do |ind1|
      env1 = cys_envs[ind1]
      #k1 = env1.seq
      comp_env1 = init_comp()
       env1.seq.split('').select{|e| e != '*'}.map{|e| comp_env1[e]+=1}
      nber_start_x= env1.seq.match(/^(X*)/)[1].size
      nber_end_x= env1.seq.match(/(X*)$/)[1].size
      (ind1 .. cys_envs.size-1).select{|ind2| ind2 != ind1}.each do |ind2|
        env2 =  cys_envs[ind2]
       # k2 = env2.seq
        comp_env2 = init_comp()
        env2.seq.split('').select{|e| e != '*'}.map{|e| comp_env2[e]+=1}
        nber_start_x2 = env2.seq.match(/^(\**)/)[1].size
        nber_end_x2 = env2.seq.match(/(\**)$/)[1].size
        longer_start_x = [ nber_start_x, nber_start_x2].max
        longer_end_x =  [ nber_end_x, nber_end_x2].max
        align_len = 11-longer_start_x - longer_end_x
        
        ### compute diff
        diff=0
        comp_env1.each_key do |aa|
          diff+= (comp_env1[aa] - comp_env2[aa]).abs
        end
        
        if (diff < 2*align_len/3 and #(nber_start_x2 - nber_start_x).abs < 3 and (nber_end_x2 - nber_end_x).abs < 3 and 
            (nber_start_x2 - nber_start_x + nber_end_x2 - nber_end_x).abs < 3 and 
             env1.seq[0..9] != env2.seq[1..10] and env2.seq[0..9] != env1.seq[1..10]
            ) 
          seqs = [ env1.seq, env2.seq].map{|x| Bio::Sequence::NA.new(x) }
          a = Bio::Alignment.new(seqs)
          #puts "############"
          #	 puts a.consensus
          #a.each { |x| p x }
          #conserved = a.consensus.split('').map{|e| e != '?'}.size
          a2 = a.do_align(factory)
          #puts a2.match_line
          match_line = a2.match_line.split('')
          conserved = match_line.select{|e| e == '*'}.size
          high_similar = match_line.select{|e| e == ':'}.size
          low_similar = match_line.select{|e| e== '.'}.size
          score = (conserved + high_similar *0.5 + low_similar *0.2)*100/align_len
          if score >= 60        
            h={
              :cys_env_id1 => env1.id,
              :cys_env_id2 => env2.id,
              :score => score.to_i
            }
            dist = Distance.find(:first, :conditions => h)
            if !dist
              dist = Distance.new(h)
              dist.save
            end
          end
        end
      end
    end
    
#    h_cys_env.keys.sort{|a, b| h_cys_env[a] <=> h_cys_env[b]}.first(10).each do |k|
#      puts k + ": " + h_cys_env[k].size.to_s       
#    end
  end
end
