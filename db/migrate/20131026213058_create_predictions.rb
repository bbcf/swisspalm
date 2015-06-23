class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|

      t.timestamps
    end
  end
end
