class CreateRefIsoforms < ActiveRecord::Migration
  def change
    create_table :ref_isoforms do |t|

      t.timestamps
    end
  end
end
