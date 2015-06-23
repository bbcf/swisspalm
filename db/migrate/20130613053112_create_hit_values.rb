class CreateHitValues < ActiveRecord::Migration
  def change
    create_table :hit_values do |t|

      t.timestamps
    end
  end
end
