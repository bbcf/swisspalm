class CreateSubcellularLocations < ActiveRecord::Migration
  def change
    create_table :subcellular_locations do |t|

      t.timestamps
    end
  end
end
