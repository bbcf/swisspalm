namespace :swisspalm do

  desc "Organism stats"
  task :organism_stats_old, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include LoadData
    
    h_features = {
        :feature_type_id => 6
    }
    all_disulfides = Feature.find(:all, :conditions => h_features)    
    
    Organism.all.each do |o|

      puts "=> " + o.name
      proteins = o.proteins
      h_proteins = {}
      proteins.map{|p| h_proteins[p.id]=p}
      isoforms = Isoform.find(:all, :conditions => {:protein_id => proteins.map{|e| e.id} })
      h_isoforms={}
      isoforms.map{|i| h_isoforms[i.id]=i}
      predictions_main_isoform = Prediction.find(:all, :conditions => {:isoform_id => isoforms.select{|i| i.main == true}.map{|i| i.id}})
      
      disulfides = all_disulfides.select{|e| h_proteins[e.protein_id]}
      h_d = {}
      disulfides.map{|d| h_d[[d.protein_id, d.start]]=1; h_d[[d.protein_id, d.stop]]=1}

      predictions_hc =  predictions_main_isoform.select{|p| p.cp_high_cutoff > 0}

      h={
        :nber_cys_in_disulfides=> h_d.keys.size,
	:nber_cys_main_isoform => predictions_main_isoform.size,
        :nber_predicted_cys_main_isoform => predictions_hc.size,
        :nber_predicted_cys_in_disulfides_main_isoform => predictions_hc.select{|pred| h_d[[h_isoforms[pred.isoform_id].protein_id, pred.pos]]}.size,
        :nber_proteins_with_predicted_cys_main_isoform => predictions_hc.map{|pred| h_isoforms[pred.isoform_id].protein_id}.uniq.size,
        :nber_proteins_with_disulfide => h_d.keys.map{|t| t[0]}.uniq.size
      }
      o.update_attributes(h)

    end
    
  end
end
