class CreateHitProteinGroups < ActiveRecord::Migration
  def change
    create_table :hit_protein_groups do |t|

      t.timestamps
    end
  end
end
