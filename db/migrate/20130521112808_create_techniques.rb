class CreateTechniques < ActiveRecord::Migration
  def change
    create_table :techniques do |t|

      t.timestamps
    end
  end
end
