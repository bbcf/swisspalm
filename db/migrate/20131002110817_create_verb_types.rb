class CreateVerbTypes < ActiveRecord::Migration
  def change
    create_table :verb_types do |t|

      t.timestamps
    end
  end
end
