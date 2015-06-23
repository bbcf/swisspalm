class CreateDataTypes < ActiveRecord::Migration
  def change
    create_table :data_types do |t|

      t.timestamps
    end
  end
end
