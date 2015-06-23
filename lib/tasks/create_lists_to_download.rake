namespace :swisspalm do

  desc "Create lists to download"
  task :create_lists_to_download, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

    data_dir = Pathname.new(APP_CONFIG[:data_dir])

    h_proteins = {}
    Protein.all.map{|p| h_proteins[p.id] = p}
    
#    File.open(data_dir + 'downloads' + 'all_seq.fa', 'w') do |f|
#      Isoform.all.each do |isoform|
#        seq = Bio::Sequence::NA.new(isoform.seq)
#        protein = isoform.protein 
#        f.write(seq.to_fasta(isoform.id.to_s + "|" + ((isoform.main == false) ? (protein.up_ac + "-" + isoform.isoform.to_s) : protein.up_ac)).upcase)
#      end
#    end    
 
#    File.open(data_dir + 'downloads' + 'main_isoforms_with_c.fa', 'w') do |f|
#      Isoform.all.select{|e| e.main == true and e.seq.match(/C/)}.sort{|a, b| a.seq.size <=> b.seq.size}.each do |isoform|
#        seq = Bio::Sequence::NA.new(isoform.seq)
#        protein = isoform.protein
#        f.write(seq.to_fasta(isoform.id.to_s).upcase)
#      end
#    end

#    File.open(data_dir + 'downloads' + 'human_main_isoforms_with_c_calx.fa', 'w') do |f|
#      Isoform.all.select{|e| h_proteins[e.protein_id].up_id == 'CALX_HUMAN' and e.main == true and e.latest_version == true and e.seq.match(/C/) and h_proteins[e.protein_id].organism_id == 1}.sort{|a, b| a.seq.size <=> b.seq.size}.each do |isoform|
#        seq = Bio::Sequence::NA.new(isoform.seq)
#        protein = isoform.protein
#        f.write(seq.to_fasta(isoform.id.to_s).upcase)
#      end
#    end

#    File.open(data_dir + 'downloads' + 'isoforms_with_c.fa', 'w') do |f|
#      Isoform.all.select{|e| e.latest_version == true and e.seq.match(/C/)}.sort{|a, b| a.seq.size <=> b.seq.size}.each do |isoform|
#        seq = Bio::Sequence::NA.new(isoform.seq)
#        protein = isoform.protein
#        f.write(seq.to_fasta(isoform.id.to_s).upcase)
#      end
#    end



  File.open(data_dir + 'downloads' + 'isoforms_with_sites_and_c.fa', 'w') do |f|

      h_sites = {}
      Site.all.map{|s| h_sites[s.hit.protein_id]=1}
	puts h_sites.keys.size
      Isoform.all.select{|e| e.latest_version == true and e.seq.match(/C/) and h_sites[e.protein_id]}.sort{|a, b| a.seq.size <=> b.seq.size}.each do |isoform|
        seq = Bio::Sequence::NA.new(isoform.seq)
        protein = isoform.protein
        f.write(seq.to_fasta(isoform.id.to_s).upcase)
      end
    end



  end
end
