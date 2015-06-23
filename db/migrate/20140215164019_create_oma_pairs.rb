class CreateOmaPairs < ActiveRecord::Migration
  def change
    create_table :oma_pairs do |t|

      t.timestamps
    end
  end
end
