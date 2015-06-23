class CreateProteinGoAssociations < ActiveRecord::Migration
  def change
    create_table :protein_go_associations do |t|

      t.timestamps
    end
  end
end
