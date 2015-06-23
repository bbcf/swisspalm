class CreateIsoforms < ActiveRecord::Migration
  def change
    create_table :isoforms do |t|

      t.timestamps
    end
  end
end
