class CreateTableHeaderCaptions < ActiveRecord::Migration
  def change
    create_table :table_header_captions do |t|

      t.timestamps
    end
  end
end
