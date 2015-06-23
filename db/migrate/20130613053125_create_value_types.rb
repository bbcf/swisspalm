class CreateValueTypes < ActiveRecord::Migration
  def change
    create_table :value_types do |t|

      t.timestamps
    end
  end
end
