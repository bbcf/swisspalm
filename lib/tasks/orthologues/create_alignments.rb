input_dir = 'ma_input/'

list_inputs = Dir.new(input_dir).entries.select{|e| !e.match(/^\./)}

list_inputs.each do |file|
  
  working_dir = "ma_muscle/"
  cmd = "muscle -quiet -clw -in #{input_dir}#{file} -out #{working_dir}#{file}.clw && muscle -quiet -html -in #{input_dir}#{file} -out #{working_dir}#{file}.html"
  puts cmd
  `#{cmd}`
  working_dir = "ma_mafft/"    
  cmd = "mafft --clustalout --quiet  #{input_dir}#{file} > #{working_dir}#{file}.clw"
  puts cmd
  `#{cmd}`
end
