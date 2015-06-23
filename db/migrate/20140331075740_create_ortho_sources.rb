class CreateOrthoSources < ActiveRecord::Migration
  def change
    create_table :ortho_sources do |t|

      t.timestamps
    end
  end
end
