class CreateGoRelations < ActiveRecord::Migration
  def change
    create_table :go_relations do |t|

      t.timestamps
    end
  end
end
