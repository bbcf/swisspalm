class CreatePalmitomeEntries < ActiveRecord::Migration
  def change
    create_table :palmitome_entries do |t|

      t.timestamps
    end
  end
end
