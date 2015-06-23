class CreateOrthodbLevels < ActiveRecord::Migration
  def change
    create_table :orthodb_levels do |t|

      t.timestamps
    end
  end
end
