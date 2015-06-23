class CreateAnnots < ActiveRecord::Migration
  def change
    create_table :annots do |t|

      t.timestamps
    end
  end
end
