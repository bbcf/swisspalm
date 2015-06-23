class CreateUniprotStatuses < ActiveRecord::Migration
  def change
    create_table :uniprot_statuses do |t|

      t.timestamps
    end
  end
end
