namespace :swisspalm do

  desc "Load isoform mapping..."
  task :load_isoform_mapping, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data'

   #### refseq mapping to isoforms

    h_seq = {}
    puts "Read existing sequences..."
    if File.exists?(dir + "refseq_proteins.fa")
      lines =[]
      File.open(dir + "refseq_proteins.fa") do |f|
        lines = f.read.split(/\n/)
      end

      ac=''
      lines.each do |l|
        if m=l.match(/^>.+?\|ref\|(.+?)\|/)
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
      if (rp = RefProtein.find(:first, :conditions => {:value => np}))
        puts "#{rp.protein.up_ac} => #{np}"
        rp.protein.isoforms.each do |iso|
          if iso.seq == h_seq[np]
            puts "isoform #{iso.isoform} => #{np}"
            #iso.update_attributes({:refseq_id => np})
            iso.ref_isoforms << RefIsoform.new({:value => np, :source_type_id => 2}) if !iso.ref_isoforms.map{|e| e.value}.include?(np)
            break
          end
        end
      end
    end


    #### tair mapping to isoforms 

    h_seq = {}
    filename = "arabidopsis_thaliana_isoform_sequences.fa"
    puts "Read existing sequences..."
    
    if File.exists?(dir + filename)
      lines =[]
      File.open(dir + filename) do |f|
        lines = f.read.split(/\n/)
      end
      
      ac=''
      lines.each do |l|
        if m=l.match(/^>(.+?)\s*\|/)
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
    
    h_seq.each_key do |tair_id|

      tab = tair_id.split(".")

      refprot = RefProtein.find(:first, :conditions => ["lower(value) = ?", tab[0].downcase])
      if refprot
        prot = refprot.protein
        iso = nil
        prot.isoforms.each do |isoform|
          if isoform.seq == h_seq[tair_id]
            iso = isoform
            break
          end
        end
        if iso
          iso.ref_isoforms << RefIsoform.new({:value => tair_id, :source_type_id => 9}) if !iso.ref_isoforms.map{|e| e.value}.include?(tair_id)
          puts "Found mapping " + tair_id + " => " + iso.isoform.to_s
        else
          puts "Unfound sequence for " +  tair_id
        end
      else
        puts "Unfound refprot for " + tair_id + " " + tab[0]
      end
    end


  end	
end
