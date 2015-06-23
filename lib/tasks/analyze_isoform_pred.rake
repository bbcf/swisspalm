namespace :swisspalm do

  desc "Analyze isoform palmitoylation predictions"
  task :analyze_isoform_pred, [:version] do |t, args|

    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'

    h_hc_preds = {}

    puts "Get predictions..."

    Prediction.find(:all, :conditions => ['cp_high_cutoff > 0']).each do |p|
      h_hc_preds[p.isoform_id]||=[]
      h_hc_preds[p.isoform_id].push(p)
    end

    puts "Get isoforms..."

    h_isoforms = {}
    Isoform.all.each do |i|
      h_isoforms[i.protein_id]||=[]
      h_isoforms[i.protein_id].push(i)
    end
    
    #    Protein.find(:all, :conditions => {:has_hits => true}).each do |protein|
    Protein.all.each do |protein|

      isoforms = h_isoforms[protein.id].select{|e| e.latest_version == true}.sort{|a, b| a.isoform <=> b.isoform}
      
      

      h_pos_ali = {}
      list_pos_ali = []
      h_pred = {}
      main_iso = ''
      isoforms.select{|i| h_hc_preds[i.id]}.each do |isoform|
        iso = isoform.isoform
        
        #        main_iso = iso if isoform.main == true

        h_pred[iso]={}
        h_pos_ali[iso]={}

	
        h_hc_preds[isoform.id].each do |pred|
          ##compute position in ali                                                                                                                                                                          
          pos_ali = 0
          cur_pos = 0
          gaps=0
          if isoform.iso_ma_mask
            isoform.iso_ma_mask.split(',').each do |mask_el|
              if mask_el[0] == ':'
                cur_pos += mask_el[1..-1].to_i
              else
                gaps+= mask_el[1..-1].to_i
              end
              if cur_pos >= pred.pos
                pos_ali = pred.pos + gaps
                break
              end
            end
          else
            pos_ali = pred.pos
          end
          h_pos_ali[iso][pos_ali]=pred.pos
          list_pos_ali.push(pos_ali) if !list_pos_ali.include?(pos_ali)
        end
      end
            
      puts protein.up_ac if list_pos_ali.size > 0
      
      list_pos_ali.each do |pos|
        tmp_list_iso = []
        tmp_list_iso_ids = []
        tmp_list_pos_isoforms = []
	isoforms.each do |isoform|
          if h_pos_ali[isoform.isoform] and  h_pos_ali[isoform.isoform][pos]
            tmp_list_iso.push(isoform.isoform)
            tmp_list_iso_ids.push(isoform.id)
            tmp_list_pos_isoforms.push(h_pos_ali[isoform.isoform][pos])
          end
	end
	if tmp_list_iso.size < isoforms.size
          puts "isoforms #{tmp_list_iso.join(", ")} over #{isoforms.size} are predicted to be palmitoylated on pos_ali #{pos}"
          h = {
            :protein_id => protein.id,
            :isoform_ids => tmp_list_iso_ids.join(","),
            :pos_isoforms => tmp_list_pos_isoforms.join(","),
            :nber_isoforms_pred => tmp_list_pos_isoforms.size,
            :nber_isoforms_total => isoforms.size,
            :pos_ali => pos            
          }
          isoform_diff_prediction = IsoformDiffPrediction.new(h)
          isoform_diff_prediction.save
          
        end
      end
    end

  end
end


