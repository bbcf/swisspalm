class CreateRefPalms < ActiveRecord::Migration
  def change
    create_table :ref_palms do |t|

      t.timestamps
    end
  end
end
