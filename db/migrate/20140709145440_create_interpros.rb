class CreateInterpros < ActiveRecord::Migration
  def change
    create_table :interpros do |t|

      t.timestamps
    end
  end
end
