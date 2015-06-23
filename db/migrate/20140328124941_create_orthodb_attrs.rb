class CreateOrthodbAttrs < ActiveRecord::Migration
  def change
    create_table :orthodb_attrs do |t|

      t.timestamps
    end
  end
end
