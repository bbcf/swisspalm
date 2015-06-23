class CreateConfidenceLevels < ActiveRecord::Migration
  def change
    create_table :confidence_levels do |t|

      t.timestamps
    end
  end
end
