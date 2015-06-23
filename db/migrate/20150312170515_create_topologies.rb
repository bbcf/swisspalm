class CreateTopologies < ActiveRecord::Migration
  def change
    create_table :topologies do |t|

      t.timestamps
    end
  end
end
