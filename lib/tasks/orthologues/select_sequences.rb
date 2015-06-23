#sp|Q5W0Z9|ZDH20_HUMAN   gi|32691358|lcl|sp!Q5W0Z9!ZDH20_HUMAN   100.00  365     0       0       1       365     1       365     0.0      733
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4752610|lcl|tr!H2NJD5_PONAB  100.00  365     0       0       1       365     1       365     0.0      733
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4770373|lcl|tr!H2Q799_PANTR  99.45   365     2       0       1       365     1       365     0.0      732
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4567385|lcl|tr!G1RS44_NOMLE  99.73   365     1       0       1       365     1       365     0.0      732
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4464279|lcl|tr!F7E5B8_MACMU  99.45   365     2       0       1       365     1       365     0.0      728
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4843948|lcl|tr!K7DNR0_PANTR  99.72   354     1       0       1       354     1       354     0.0      711
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4800527|lcl|tr!H9FSD9_MACMU  99.44   354     2       0       1       354     1       354     0.0      706
#sp|Q5W0Z9|ZDH20_HUMAN   gi|2099182|lcl|tr!I6L9D4_HUMAN  99.72   354     0       1       1       354     1       353     0.0      705
#sp|Q5W0Z9|ZDH20_HUMAN   gi|32726700|lcl|sp!Q5W0Z9-3     99.72   354     0       1       1       354     1       353     0.0      705
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4464271|lcl|tr!F7E5A5_MACMU  99.15   354     2       1       1       354     1       353     0.0      699
#sp|Q5W0Z9|ZDH20_HUMAN   gi|4335182|lcl|tr!E2REV5_CANFA  94.52   365     20      0       1       365     1       365     0.0      699

require 'rubygems'
require 'json'

h_nr_species={}
h_species={}

blast_dir='blast_results'
working_dir = '~/Marion/'
Dir.new(blast_dir).entries.select{|e| !e.match(/^\./)}.each do |file|
  puts "Reading blasting #{file}..."
  
  h_species[file]={}
  
  File.open("#{blast_dir}/#{file}", 'r') do |f|
    f.readlines.each do |l|
      tab = l.split(/\|/)
      id = tab[5].split(/\s+/)[0].split(/\!/)[-1]
    #  if !l.match(/\-/) and m = l.match(/(tr|sp)\!([\w_]+)/)
#      puts id
      tab2 = id.split("_")
      if tab2.size == 2
        species = tab2[1]
        #     puts species
        h_species[file][species]=id if !h_species[file][species]
        h_nr_species[species]=1
        #  end
      else
        
      end
  end
end


list_species = h_nr_species.keys.select{|e| e}.select{|e|  h_species.keys.select{|g| h_species[g][e]}.size > 20}.sort
final_list_orthologues = []

File.open("organisms.csv", 'w') do |f2|
  
  f2.write(["Files", list_species].flatten.join(',') + "\n")
  f2.write(["", list_species.map{|e| h_species.keys.select{|g| h_species[g][e]}.size }].flatten.join(',') + "\n")

  h_species.each_key do |file|
    
    t = [file]
    
    list_species.each do |species|
      t.push((h_species[file][species]) ? h_species[file][species] : 'NA')
      final_list_orthologues.push(h_species[file][species]) if h_species[file][species]
    end
    
    f2.write( t.join(",") + "\n")
  end
end


File.open("list_seq_orthologues.csv", 'w') do |f2|
  f2.write(final_list_orthologues.join("\n") + "\n")
end
