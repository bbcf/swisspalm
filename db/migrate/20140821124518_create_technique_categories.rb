class CreateTechniqueCategories < ActiveRecord::Migration
  def change
    create_table :technique_categories do |t|

      t.timestamps
    end
  end
end
