class CreateSubcellularFractions < ActiveRecord::Migration
  def change
    create_table :subcellular_fractions do |t|

      t.timestamps
    end
  end
end
