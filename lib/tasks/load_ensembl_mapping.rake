namespace :swisspalm do

  desc "Load  mapping..."
  task :load_ensembl_mapping, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'


    Organism.all.each do |o|
      h_seq = {}
      puts "Read existing sequences..."
      infile = dir + "#{o.taxid}.ensembl.fa.gz"
      if File.exists?(infile)
	
        gz = Zlib::GzipReader.new(infile)
        
        h_oma_mapping = {}
        flag_organism_ok=0
        gz.each_line do |l|
          l.chomp!

          if m=l.match(/^>(\w+?) /)
            ac = m[1]	 
            if h_seq[ac]
              puts "error with #{ac}"
            else
              h_seq[ac]=''
            end
          else
            h_seq[ac]+=l
          end
        end
      end
      
      h_seq.each_key do |np|
        if rp = RefProtein.find_by_value(np)
          puts "#{rp.protein.up_ac} => #{np}"
          rp.protein.isoforms.select{|i| i.latest_version == true}.each do |iso|
            if iso.seq == h_seq[np]
              puts "isoform #{iso.isoform} => #{np}"
              iso.update_attributes({:refseq_id => np})
              iso.ref_isoforms << RefIsoform.new({:value => np, :source_type_id => 12}) if !iso.ref_isoforms.map{|e| e.value}.include?(np)
              break
            end
          end
        end
      end
    end


  end	
end
