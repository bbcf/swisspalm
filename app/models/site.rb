class Site < ActiveRecord::Base

  has_many :reactions
  has_and_belongs_to_many :techniques
  belongs_to :hit
  belongs_to :organism
  belongs_to :subcellular_fraction
  belongs_to :cell_type
  belongs_to :cys_env

  attr_accessible :pos, :hit_id, :required_mod, :in_uniprot, :validator_id, :curator_id, :study_id, :protein_id, 
  :isoform_text, :transferase_text, :esterase_text, :study_text, :protein_text, 
  :organism_id, :cell_type_id, :subcellular_fraction_id, :technique_ids, :user_id, :uncertain_pos, :cys_env_id

  attr_accessor :study_id, :protein_id, 
  :isoform_text, 
  :transferase_text, :esterase_text,
  :protein_text, :study_text

  validate :valid_protein
  validate :valid_study
  validate :valid_transferases
  validate :valid_esterases
  validate :cys_at_pos

  after_save :save_history

  def save_history    
    h={
      :site_id => self.id,
      :pos  => self.pos,
      :hit_id => self.hit_id,
      :organism_id => self.organism_id,
      :cell_type_id => self.cell_type_id,
      :subcellular_fraction_id => self.subcellular_fraction_id,
      :required_mod => self.required_mod,
      :in_uniprot => self.in_uniprot,
      :created_at => Time.now,
      :curator_id => self.curator_id,
      :validator_id => self.validator_id,
      :user_id => self.user_id,
      :technique_ids => self.techniques.map{|t| t.id}.sort.join(','),
      :reaction_ids => self.reactions.map{|r| r.id}.sort.join(','),
      :uncertain_pos => self.uncertain_pos
    }
    history_site = HistorySite.new(h)
    history_site.save
  end
  
  def valid_protein
    errors.add(:base, "Invalid protein") if !hit or !hit.protein
  end
  
  def valid_study
     errors.add(:base, "Invalid study") if !hit or !hit.study
  end

  def valid_transferases
    if transferase_text
      list_bad_names=[]
      transferase_text.split(/\s*,\s*/).each do |transferase|
        list_bad_names.push(transferase) if !Protein.find_by_up_ac(transferase)
      end
      errors.add(:base, "Invalid transferases " + list_bad_names.join(', ')) if list_bad_names.size > 0
    end
  end
  def valid_esterases
    if esterase_text
      list_bad_names=[]
      esterase_text.split(/\s*,\s*/).each do |esterase|
        list_bad_names.push(transferase) if !Protein.find_by_up_ac(esterase)
      end
      errors.add(:base, "Invalid esterases " + list_bad_names.join(', ')) if list_bad_names.size > 0
    end
  end
  
  
  def cys_at_pos
    if hit
      isoforms =  hit.protein.isoforms.select{|i| i.latest_version}
      main_isoform = isoforms.select{|e| e.main}.first
      iso = (hit.isoform) ? hit.isoform : 
        ((main_isoform) ? main_isoform : 
         ((isoforms.size == 1) ? isoforms[0] : nil))
#      logger.debug(pos.to_json + "----->" + iso.seq[pos-1] + "--" + iso.to_json)
      errors.add(:base, "Not a cysteine at this position in the sequence") if pos and iso.seq[pos-1] != 'C'    
    end
  end
    
end
