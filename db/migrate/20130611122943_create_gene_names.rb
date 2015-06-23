class CreateGeneNames < ActiveRecord::Migration
  def change
    create_table :gene_names do |t|

      t.timestamps
    end
  end
end
