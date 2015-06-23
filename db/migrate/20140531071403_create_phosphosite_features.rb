class CreatePhosphositeFeatures < ActiveRecord::Migration
  def change
    create_table :phosphosite_features do |t|

      t.timestamps
    end
  end
end
