class CreateCysteines < ActiveRecord::Migration
  def change
    create_table :cysteines do |t|

      t.timestamps
    end
  end
end
