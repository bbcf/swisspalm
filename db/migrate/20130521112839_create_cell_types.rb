class CreateCellTypes < ActiveRecord::Migration
  def change
    create_table :cell_types do |t|

      t.timestamps
    end
  end
end
