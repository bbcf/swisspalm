class CreatePhosphositeTypes < ActiveRecord::Migration
  def change
    create_table :phosphosite_types do |t|

      t.timestamps
    end
  end
end
