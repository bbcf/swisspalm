class CreateTmpPalmitomeEntries < ActiveRecord::Migration
  def change
    create_table :tmp_palmitome_entries do |t|

      t.timestamps
    end
  end
end
