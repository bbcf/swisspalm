class CreateOmaRelationTypes < ActiveRecord::Migration
  def change
    create_table :oma_relation_types do |t|

      t.timestamps
    end
  end
end
