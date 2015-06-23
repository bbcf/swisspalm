namespace :swisspalm do

  desc "Create history"
  task :create_history, [:version] do |t, args|
    
    ### Use rails enviroment                                                                                                                                                                         
    require "#{Rails.root}/config/environment"
    
    ### Require Net::HTTP                                                                                                                                                                            
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'mechanize'
    require 'hpricot'
    include Fetch

    
    ### history for studies

    Study.all.each do |study|
      
      h={
        :study_id => study.id,
        :pmid => study.pmid,
        :organism_id => study.organism_id,
        :subcellular_fraction_id => study.subcellular_fraction_id,
	:cell_type_id => study.cell_type_id,
        :large_scale => study.large_scale,
        :hidden => study.hidden,
        :user_id => study.user_id,
        :created_at => study.created_at,
        :technique_ids => study.techniques.map{|t| t.id}.sort.join(',')
      }
      history_study = HistoryStudy.find(:first, :conditions => h)
      if !history_study
        history_study = HistoryStudy.new(h)
        history_study.save
      end
    end

    ### history for sites
    
    Site.all.each do |site|

      h={
        :site_id => site.id,
        :pos  => site.pos,
        :hit_id => site.hit_id,
        #      :organism_id => site.organism_id,
        #      :cell_type_id => site.cell_type_id,
        #      :subcellular_fraction_id => site.subcellular_fraction_id,
        :required_mod => site.required_mod,
        :in_uniprot => site.in_uniprot,
        :created_at => site.updated_at,
        :curator_id => site.curator_id,
        :validator_id => site.validator_id,
        :user_id => nil,
        :technique_ids => site.techniques.map{|t| t.id}.sort.join(','),
        :reaction_ids => site.reactions.map{|r| r.id}.sort.join(',')
      }
      history_site = HistorySite.find(:first, :conditions => h)
      if !history_site
        history_site = HistorySite.new(h)
        history_site.save
      end
      
    end
  end	
end
