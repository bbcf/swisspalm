class Study < ActiveRecord::Base

  has_and_belongs_to_many :techniques
  has_many :hit_lists
  has_many :hits
  belongs_to :subcellular_fraction
  belongs_to :cell_type
  belongs_to :organism
  belongs_to :user
  has_many :history_studies
  
#  belongs_to :article
   attr_accessible :id, :name, :title, :authors, :pmid, :year, 
  :organism_id, :cell_type_id, :subcellular_fraction_id, 
  :large_scale, :hidden, :in_vitro, 
  :user_id, :created_at, :updated_at, :technique_ids, :parent_id,
  :prot_common_in_palmitomes_json, :prot_diff_in_palmitomes_json,
  :prot_common_in_palmitomes_json_val, :prot_diff_in_palmitomes_json_val

  
  after_save :save_history, :update_add_article
 
  def save_history
  
    h={
      :study_id => self.id,
      # :authors => self.authors,
      # :year => self.year,
      :name => self.name,
      :pmid => self.pmid,
      :organism_id => self.organism_id,
      :cell_type_id => self.cell_type_id,
      :subcellular_fraction_id => self.subcellular_fraction_id,
      :large_scale => self.large_scale,
      :hidden => self.hidden,
      :in_vitro => self.in_vitro,
      :user_id => self.user_id,
      :created_at => Time.now,
      :technique_ids => self.techniques.map{|t| t.id}.sort.join(',')    
    }
    history_study = HistoryStudy.new(h)
    history_study.save
  end
  
  def update_add_article
 
    h={
      :pmid => self.pmid
    }
    
    article = Article.find(:first, :conditions => h)
    if !article
      h={
        :pmid => self.pmid,
        :title => self.title,
        :authors => self.authors,                                                                             
        :year => self.year  
      }
      article = Article.new(h)
      article.save
      #   else
      #      article.update_attributes({:authors => self.authors, :year => self.year})
    end

  end

end
