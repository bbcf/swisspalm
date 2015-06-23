namespace :swisspalm do

  desc "Compute BLASTs"
  task :compute_blast, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch

    blast_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues' + 'blast_results'

   # seq_dir='sequences'
    
    working_dir = '/data/epfl/bbcf/swisspalm/orthologues/'

    list_cmds=[]
    
    f = File.open('commands.txt', 'w')

   # proteins = Protein.find(:all, :conditions => {:is_a_pat => true})
    proteins =    (Protein.find(:all, :conditions => {:is_a_pat => true}) | Protein.find(:all, :conditions => {:is_a_pat => false}) | Protein.find(:all, :conditions => {:has_hits => true}))
    proteins.each do |protein|
      protein.isoforms.each do |isoform| 

        outfile =blast_dir + (protein.up_ac + "-" + isoform.isoform.to_s + '.txt')
        
        if !File.exists?(outfile) or File.new(outfile).size == 0
          
          seq = Bio::Sequence::AA.new(isoform.seq)
          
          ### write fasta file                                                                                                                              
          puts "write file: " + protein.up_ac + "-" + isoform.isoform.to_s
          infile = working_dir + 'sequences/' + (protein.up_ac + "-" + isoform.isoform.to_s + '.fa')
          File.open(infile, 'w') do |f|
            f.write(seq.to_fasta(isoform.id.to_s + '|' + protein.up_ac + "-" + isoform.isoform.to_s))
            #       puts seq.to_fasta(isoform.id.to_s + '|' + protein.up_ac + "-" + isoform.isoform)
          end

          puts "Blasting #{protein.up_ac}-#{isoform.isoform}..."
#          list_cmds.push( "cd /db/scratch/expasy/new_blast/Oct-2013/ && blastall -p blastp -d new_UniProtKB -m 8 -i #{infile} -o #{outfile} && rm #{infile}")
          list_cmds.push( "cd /db/scratch/expasy/data/blast/formatdb/ && blastall -p blastp -d UniProtKB -m 8 -i #{infile} -o #{outfile} && rm #{infile}")

          #  `#{cmd}`

          if list_cmds.size == 100
            cmd = "echo '" + list_cmds.join("\n") + "' | xargs -P 50 -I {} sh -c '{}'"
         #   `#{cmd}`
            f.write(cmd)
            list_cmds=[]            
          end
          
        end
      end
    end

    cmd = "echo '" + list_cmds.join("\n") + "' | xargs -P 50 -I {} sh -c '{}'"
   # `#{cmd}`
    f.write(cmd)

    f.close

  end
end
