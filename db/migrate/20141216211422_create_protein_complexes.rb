class CreateProteinComplexes < ActiveRecord::Migration
  def change
    create_table :protein_complexes do |t|

      t.timestamps
    end
  end
end
