namespace :swisspalm do

  desc "Create isoform multiple alignment"
  task :create_isoform_ma, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

    working_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'isoform_ma'
    
#    Protein.find(:all, :conditions => {:has_hits => true}).each do |protein|
    Protein.all.each do |protein|
      isoforms = protein.isoforms.select{|e| e.latest_version}
      if isoforms.size > 1

        h_isoforms = {}
        isoforms.each do |isoform|
          id = protein.up_ac + ((isoform.main == true) ? "" : "-#{isoform.isoform}")
          h_isoforms[id]=isoform.seq
        end
        
        output_file = working_dir + (protein.up_ac + ".clw")
        
        to_compute = 1
        
        if File.exists?(output_file)
       
          to_compute = 0
          aln = Bio::ClustalW::Report.new(File.read(output_file))
          h_seqs = {}
          i=0
          
          while s = aln.get_sequence(i) do 
            h_seqs[s.definition]=s.seq.gsub(/-+/, '')
            i+=1
          end
                
          if h_seqs.keys.size != isoforms.size
            to_compute = 1
            puts "Not the same number of sequences: " + h_seqs.keys.size.to_s + "/" +  isoforms.size.to_s
          else
            h_isoforms.each_key do |definition|
              if !h_seqs[definition]
                to_compute = 1
                puts "Unavalable sequence for #{definition}"
              elsif h_seqs[definition] != h_isoforms[definition]
                to_compute = 1
                puts "Not the same sequences:\n" +  h_seqs[definition] + "\n" + h_isoforms[definition]
              end
            end
          end
        end
        
        #puts to_compute
        #        exit
        if to_compute == 1 
          puts "Do alignment for #{protein.up_ac}..."
          fasta = ''
          isoforms.sort{|a, b| a.isoform <=> b.isoform}.each do |isoform|
            seq = Bio::Sequence::NA.new(isoform.seq)
            fasta+=seq.to_fasta((isoform.main == false) ? (protein.up_ac + "-" + isoform.isoform.to_s) : protein.up_ac)
          end
          #	puts fasta 
          #	exit
          file = "/tmp/ali_tmp_file"
          File.open(file, 'w')  do |f|
            f.write(fasta)
          end
          
          cmd = "mafft --clustalout --quiet  #{file} > #{output_file}"
          puts cmd
          `#{cmd}`
          
        end
      end
    end
    
  end
end


