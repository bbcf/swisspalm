class CreateHistoryStudies < ActiveRecord::Migration
  def change
    create_table :history_studies do |t|

      t.timestamps
    end
  end
end
