seq_dir='sequences'
working_dir = '/data/epfl/bbcf/swisspalm/orthologues/'
Dir.new(working_dir + seq_dir).entries.select{|e| !e.match(/^\./)}.each do |file|
  puts "Blasting #{file}..."
  cmd = "cd /db/scratch/expasy/new_blast/Oct-2013/ && blastall -p blastp -d new_UniProtKB -m 8 -i #{working_dir}sequences/#{file} -o #{working_dir}blast_results/#{file}"
  `#{cmd}`
end
