class CreateProteinGroups < ActiveRecord::Migration
  def change
    create_table :protein_groups do |t|

      t.timestamps
    end
  end
end
