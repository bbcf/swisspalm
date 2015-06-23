namespace :swisspalm do

  desc "Compute conservation"
  task :compute_conservation, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    
    orthologues_dir =  Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues'
    blast_dir = orthologues_dir  + 'blast_results'
    
    ## open blosum62
    list_i = []
    h_scores={}
    open("/data/epfl/bbcf/swisspalm/orthologues/blosum62.txt", 'r') do |f|
      while l = f.gets do 
        if !l.match(/^\#/)
          if m = l.match(/^([\w*])\s+(.+)/)
            aa1 = (m[1] == '*') ? '-' : m[1]
            t = m[2].split(/\s+/)
            h_scores[aa1]={}
            t.each_index do |j|
              aa2= (list_i[j] == '*') ? '-' : list_i[j]
              h_scores[aa1][aa2] = t[j].to_i+4
            end
          else
            list_i = l.strip.split(/\s+/)
          end
        end
      end
    end

    puts h_scores['-'].to_json

    # seq_dir='sequences'
    
    working_dir = '/data/epfl/bbcf/swisspalm/orthologues/'
    
    list_cmds=[]

    # proteins = Protein.find(:all, :conditions => {:is_a_pat => true})
    proteins =    (Protein.find(:all, :conditions => {:is_a_pat => true}) | Protein.find(:all, :conditions => {:is_a_pat => false}) | Protein.find(:all, :conditions => {:has_hits => true}))
    proteins.each do |protein|
      protein.isoforms.each do |isoform| 

        h_pred = {}
        Prediction.find_all_by_isoform_id(isoform.id).map{|pred|
          h_pred[pred.isoform_id]={}
          h_pred[pred.isoform_id][pred.pos]=pred
        }


        outfile =blast_dir + (protein.up_ac + "-" + isoform.isoform.to_s + '.txt')
        
        if File.exists?(outfile)

          list_up_ids = []
          list_isoforms = []

          File.open(outfile, 'r') do |f|
            while( l = f.gets) do 
              tab = l.chomp.split("\t")
              if tab[2].to_f > 60 and tab[10].to_f < 10**(-6)
                t =  tab[1].split("!")
        	up_id = t.last        
                if tab.size == 3
                  identifier = t[-2]
                  t2 = identifier.split('-')
                  up_ac = t2.first
                  isoform = (t2.size ==2) ? t2.last : nil
                  list_isoforms.push([up_ac, isoform])
                else
                  list_up_ids.push(up_id)
                end
                list_up_ids.push(up_id)
              end
            end
          end

          target_proteins = Protein.find_all_by_up_id(list_up_ids) 
          isofs = []
          isofs = Isoform.find_all_by_protein_id(target_proteins.map{|p| p.id})
          
          h_proteins = {}
          Protein.find_all_by_up_ac(list_isoforms.map{|e| e.first}).map{|p| h_proteins[p.up_ac]=p}

          list_isoforms.each do |isoform_item|
            iso = Isoform.find(:first, :conditions => {:protein_id => h_proteins[isoform_item[0]], :isoform => isoform_item[1]})
            isofs.push(iso)
          end
          
          puts isofs.size
          if isofs.size > 1 
            puts "Do alignment..."
            
            ##create input file
            infile = orthologues_dir + 'tmp_ma_input.fa'
            File.open(infile, 'w') do |f|
              isofs.each do |iso|
                protein = iso.protein #)h_proteins[isoform.protein_id]
                seq = Bio::Sequence::AA.new(iso.seq)
                f.write(seq.to_fasta(iso.id.to_s + '|' + protein.up_ac + "-" + iso.isoform.to_s))
                #       puts seq.to_fasta(isoform.id.to_s + '|' + protein.up_ac + "-" + isoform.isoform)
              end
            end
            
            msa_outfile = orthologues_dir + 'tmp_ali.out' 
            
            cmd = "mafft --quiet  #{infile} > #{msa_outfile}"
            `#{cmd}`
            
            ### get position of cys
            
            file = Bio::FastaFormat.open(msa_outfile)
            msa_sequences = {}
            list_msa_sequences = []
            mean_scores=[]
            
            file.each do |entry|
              puts entry.entry_id
              list_msa_sequences.push(entry.seq)
              msa_sequences[entry.entry_id]=entry.seq
              
            end
            list_pos = []
            matrix_pos = []
            final_scores = []

            h_pos = {}            
            ref_seq = list_msa_sequences.first
            pos_in_seq = 0
            (0 .. ref_seq.size-1).to_a.each do |i|
              if ref_seq[i] != '-'
                pos_in_seq += 1
              end
              if ref_seq[i] == 'C'
                h_pos[i]=pos_in_seq
                list_pos.push(i)
                matrix_pos.push(['C'])
                final_scores.push(0)
              end
            end
            
            (1 .. list_msa_sequences.size-1).to_a.each do |j|
              mean_scores[j]=0
              nber_non_gaps =0
              (0 .. ref_seq.size-1).to_a.each do |i|
                nber_non_gaps+=1 if ref_seq[i] != '-' or list_msa_sequences[j][i] != '-'
               # puts "->" + ref_seq[i]
               # puts "-->" + list_msa_sequences[j][i]
               # puts "=>" + h_scores[ref_seq[i]][list_msa_sequences[j][i]].to_s
                mean_scores[j]+=h_scores[ref_seq[i]][list_msa_sequences[j][i]]
              end
              mean_scores[j]/=nber_non_gaps
              list_pos.each_index do |i|
                pos = list_pos[i]
		
                matrix_pos[i][j]=list_msa_sequences[j][pos]
                #	puts pos.to_s  + ", " + i.to_s + ", " + j.to_s + ", " + ref_seq[pos] + ", " + list_msa_sequences[j][pos];
                #        puts mean_scores[j]
                #	puts h_scores[ref_seq[pos]][list_msa_sequences[j][pos]]
                final_scores[i]+=h_scores[ref_seq[pos]][list_msa_sequences[j][pos]]/mean_scores[j] if mean_scores[j]!=0
              end
            end
            
            final_scores.each_index do |i|
              final_scores[i]= final_scores[i].to_f/list_msa_sequences.size-1              
              prediction = h_pred[isoform.id][h_pos[list_pos[i]]]
              prediction.update_attribute(:cons_score, final_scores[i]) if prediction
            end
            
            puts final_scores.to_json
            
            #          exit 0; 
          end
        end
      end	
    end
    
  end
end
