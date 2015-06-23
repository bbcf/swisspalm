namespace :swisspalm do

  desc "Update false positif flag"
  task :update_falsepos_flag, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'

    include LoadData

    h_proteins = {}
    Protein.all.map{|p| h_proteins[p.up_ac]= p}

    h_keywords_by_cat = { 
      1 =>[
         #  'thioester',
         #  'acetyl coa',
         #  'acyl coa',
           'acyltransferase',
           '"acyl transferase"',
          ],
      2 => [
            'database:(type:unipathway AND (UPA00656 or UPA01037 or UPA00658 or UPA00661 or UPA01038 or UPA00660 or UPA00569 or UPA00199 or UPA00094 or UPA00659 or UPA01022 or UPA01039) )'
#            'database:(type:unipathway AND map0071)',
#            'database:(type:kegg AND map1040)',
#            'database:(type:kegg AND map0061)',
#            'database:(type:kegg AND map0062)',
            #            'database:(type:kegg AND map1212)'
           ],
	3 => [
	'go:(0006099 or 0006631)'
	]
    }
    
#    h_keywords_by_cat[2].each_key do |id|
#      h_keywords_by_cat[2][id]="database:(type:unipathway AND )"
#    end
    h_fp = {}
    
    Organism.all.each do |o|
    
      h_keywords_by_cat.each_key do |cat|
        
        keywords = h_keywords_by_cat[cat].map{|e| e.gsub(/ /, "+")}.join("+OR+")
        
        url = "http://www.uniprot.org/uniprot/?query=(taxonomy%3a%22#{o.taxid}%22)+AND+(#{keywords})&force=yes&format=list" 
        
        puts url
        
        `wget -O - '#{url}'`.split("\n").each do |l|
          h_fp[l.strip]||={}
          h_fp[l.strip][cat]=1
        end

      end

    end
    

    ### get features                                                                                                                                                                     
    
    features = []
    ['thioester', 'acetyl coa', 'acyl coa'].each do |e|
      features += Feature.find(:all, :conditions => ["feature_type_id in (?) and description ~ ?", [7, 14], e])
    end
    features.each do |f|
      h_fp[f.protein_id]||={}
      h_fp[f.protein_id][1]=1
    end
    
    ### update database
    
    h_fp.each_key do |up_ac|
      #	        puts "-#{up_ac}-"
      h ={}
      h[:fp_label]= true if h_fp[up_ac][1]
      h[:fp_chem]= true if h_fp[up_ac][2]
      h[:fp_go]= true if h_fp[up_ac][3]
      h_proteins[up_ac].update_attributes(h) if h_proteins[up_ac]
    end
    

    #    puts h_fp[1].keys.size
    #    h_fp[1]
    #    puts h_fp[2].keys.size
    
  end

end


