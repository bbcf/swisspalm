class CreateDiseases < ActiveRecord::Migration
  def change
    create_table :diseases do |t|

      t.timestamps
    end
  end
end
