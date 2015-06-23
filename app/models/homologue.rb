class Homologue < ActiveRecord::Base
   attr_accessible :isoform_id1, :isoform_id2, :evalue_power, :ali_len, :id_percent
end
