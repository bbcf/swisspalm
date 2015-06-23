class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|

      t.timestamps
    end
  end
end
