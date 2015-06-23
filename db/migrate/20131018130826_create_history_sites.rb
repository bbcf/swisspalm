class CreateHistorySites < ActiveRecord::Migration
  def change
    create_table :history_sites do |t|

      t.timestamps
    end
  end
end
