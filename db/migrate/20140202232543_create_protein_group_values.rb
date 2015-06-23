class CreateProteinGroupValues < ActiveRecord::Migration
  def change
    create_table :protein_group_values do |t|

      t.timestamps
    end
  end
end
