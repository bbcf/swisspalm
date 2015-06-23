class CreateRefProteins < ActiveRecord::Migration
  def change
    create_table :ref_proteins do |t|

      t.timestamps
    end
  end
end
