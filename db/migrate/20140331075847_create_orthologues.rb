class CreateOrthologues < ActiveRecord::Migration
  def change
    create_table :orthologues do |t|

      t.timestamps
    end
  end
end
