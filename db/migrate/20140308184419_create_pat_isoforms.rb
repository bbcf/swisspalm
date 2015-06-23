class CreatePatIsoforms < ActiveRecord::Migration
  def change
    create_table :pat_isoforms do |t|

      t.timestamps
    end
  end
end
