class CreateTechniqueClasses < ActiveRecord::Migration
  def change
    create_table :technique_classes do |t|

      t.timestamps
    end
  end
end
