class Isoform < ActiveRecord::Base

  belongs_to :protein
  has_many :ref_isoforms
  has_many :hits
  has_many :predictions
  has_many :cysteines
  
  has_one :pat_isoform

   attr_accessible :protein_id, :isoform, :seq, :main, :refseq_id, :iso_ma_mask, :latest_version
end
