class CreateHitLists < ActiveRecord::Migration
  def change
    create_table :hit_lists do |t|

      t.timestamps
    end
  end
end
