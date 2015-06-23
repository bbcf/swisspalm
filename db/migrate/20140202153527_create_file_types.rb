class CreateFileTypes < ActiveRecord::Migration
  def change
    create_table :file_types do |t|

      t.timestamps
    end
  end
end
