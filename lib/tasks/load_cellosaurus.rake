namespace :swisspalm do

  desc "Load Cellosaurus"
  task :load_cellosaurus, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                          
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'iconv'

    file = Pathname.new(APP_CONFIG[:data_dir]) + 'primary_data' + 'cellosaurus.txt'

    puts file
    lines = []

    File.open(file, 'r') do |f|
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      valid_string = ic.iconv(f.read)
      lines = valid_string.split(/\n/)
    end

    #ID   #15310-LN
    #AC   CVCL_E548
    #SY   TER461
    #DR   dbMHC; 48439
    #DR   ECACC; 94050311
    #DR   IHW; IHW9326
    #DR   IMGT/HLA; 10074
    #WW   http://ml570.istge.it/ecbr/cl326.html
    #CC   Part of 12th International Histocompatibility Workshop (12IHW) cell line panel.
    #OX   NCBI_TaxID=9606; ! Homo sapiens
    #SX   Female
    #CA   Transformed cell line
    #//
    
    
    id=''	
    flag=0
    lines.each do |l|
      if l.match(/^ID   #15310-LN/)
        flag=1
      end
      if flag==1
#        puts l
        if m=l.match(/^ID\s+(.+)[\s\r]*/)
          #      if m=l.match(/^AC\s+(.+)[\s\r]*/)
          id = m[1]
        elsif m=l.match(/^AC\s+(.+)[\s\r]*/)
          # h_name[ac] = m[1]
          h={:name => id, :ac => m[1]}
          cellosaurus_cell_type = CellosaurusCellType.find(:first, :conditions => {:name => id})
          if !cellosaurus_cell_type
            cellosaurus_cell_type = CellosaurusCellType.new(h)
            cellosaurus_cell_type.save
          else
            cellosaurus_cell_type.update_attributes(h)
          end
        end
      end
    end
    
  end
end

