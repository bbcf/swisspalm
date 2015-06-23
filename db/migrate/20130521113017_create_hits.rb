class CreateHits < ActiveRecord::Migration
  def change
    create_table :hits do |t|

      t.timestamps
    end
  end
end
