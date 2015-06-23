class CreateOrthodbBestOrthologues < ActiveRecord::Migration
  def change
    create_table :orthodb_best_orthologues do |t|

      t.timestamps
    end
  end
end
