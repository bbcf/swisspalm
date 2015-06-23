class CreateHomologues < ActiveRecord::Migration
  def change
    create_table :homologues do |t|

      t.timestamps
    end
  end
end
