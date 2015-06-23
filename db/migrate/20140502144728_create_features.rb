class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|

      t.timestamps
    end
  end
end
