namespace :swisspalm do

  desc "Load phosphosite data"
  task :load_phosphosite, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root.to_s}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'csv'
    require 'json'
	require 'iconv'    
    ### open file

    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    dir = Pathname.new(APP_CONFIG[:data_dir]) + 'downloads'

    feature_files = [
#                     'Acetylation_site_dataset',
#                     'Ubiquitination_site_dataset',
                     'Methylation_site_dataset',
                     'Sumoylation_site_dataset',
#                     'Phosphorylation_site_dataset'
                    ]
    
    disease_file = 'Disease-associated_sites'    
    
    h_phosphosite_types = {}
    PhosphositeType.all.map{|e| h_phosphosite_types[e.name.upcase]=e}

    h_proteins={}
    h_isoforms={}
    Protein.all.each do |p|
      h_proteins[p.up_ac]=p
      h_isoforms[p.id]={}
    end

    Isoform.all.each do |i|
      h_isoforms[i.protein_id][i.isoform]=i
    end

    feature_files.each do |file|
      
      filepath = dir + 'phosphosite' + file
      
      if File.exists?(filepath)
        puts "====>" + filepath.to_s
        #FB      FBgn0043467     064Ya           GO:0048149      FB:FBrf0131396|PMID:11086999    IMP             P       064Ya           gene_product    taxon:7227      20060803        FlyBase
        
        list_fields=[:protein, :up_ac,  :gene_name, 
                     :chr_loc, :mod_type, :mod_aa, :site_grp_id, 
                     :organism,  :mass, :in_domain, :site_seq, 
                     :pubmed_ltp, :pubmed_ms2, :cst_ms2, :cst_cat]
        
        File.open(filepath, 'r') do |f|
          while(l = f.gets()) do
            l = ic.iconv(l.chomp)
            tab = l.split("\t")
            
            if tab.size > 10
              h_content = {}
              tab.each_index do |i|
                h_content[list_fields[i]]=tab[i]
              end
              
              t = h_content[:up_ac].split("-")
              up_ac = t[0]
              # puts h_content[:up_ac]
              # puts up_ac
              protein = h_proteins[up_ac]
              if protein
                isoforms = protein.isoforms
                isoform = nil
                if t.size > 1
                  isoform = isoforms.select{|e| e.isoform == t[1].to_i and e.latest_version == true}.first 
                else
                  isoform = isoforms.select{|e| e.main == true and e.latest_version == true}.first
                end
                if isoform	
                  aa = nil
                  pos = nil
                  if m = h_content[:mod_aa].match(/^(\w)(\d+)/)
                    aa = m[1]
                    pos = m[2].to_i
                  end
                  if !aa or !pos
                    puts "Cannot parse modified position:" + l
                  elsif aa != isoform.seq[pos-1]
                    puts "Sequence doesn't match! #{aa} <=> #{isoform.seq[pos-1]}"
                  else 
                    h_phosphosite_feature = {
                      :phosphosite_type_id => h_phosphosite_types[h_content[:mod_type]].id,
                      :isoform_id => isoform.id,
                      :pos => pos,
                      :pubmed_ltp => h_content[:pubmed_ltp] || 0,
                      :pubmed_ms2 => h_content[:pubmed_ms2] || 0
                    }
                    
                    phosphosite_feature = PhosphositeFeature.new(h_phosphosite_feature)
                    phosphosite_feature.save
                  end
                else
                  puts "Isoform not found: " + t.to_json 
                end
              else
  #              puts "Protein not found: " + t.to_json
              end
            else
#              puts tab.size
#              puts l
#              puts tab.to_json
            end
          end
        end
      end      
    end
    
    filepath = dir + disease_file
    if File.exists?(filepath)
      list_fields = [:disease, :alteration, :protein, :up_ac, :gene_name,
                     :chr_loc, :mass, :organism, :mod_type, :site_grp_id, :mod_aa,
                     :in_domain, :site_seq, :psp_article_id,
                     :ltp_ref_count, :htp_ref_count, :cst_ms_count, :cst_cat, :notes]
      
    end
  end
end
