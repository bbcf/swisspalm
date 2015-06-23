class CreateSourceTypes < ActiveRecord::Migration
  def change
    create_table :source_types do |t|

      t.timestamps
    end
  end
end
