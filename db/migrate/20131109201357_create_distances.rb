class CreateDistances < ActiveRecord::Migration
  def change
    create_table :distances do |t|

      t.timestamps
    end
  end
end
