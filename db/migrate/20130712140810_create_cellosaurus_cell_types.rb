class CreateCellosaurusCellTypes < ActiveRecord::Migration
  def change
    create_table :cellosaurus_cell_types do |t|

      t.timestamps
    end
  end
end
