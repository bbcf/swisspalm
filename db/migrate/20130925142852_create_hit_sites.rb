class CreateHitSites < ActiveRecord::Migration
  def change
    create_table :hit_sites do |t|

      t.timestamps
    end
  end
end
