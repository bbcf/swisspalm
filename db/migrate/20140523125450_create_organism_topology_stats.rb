class CreateOrganismTopologyStats < ActiveRecord::Migration
  def change
    create_table :organism_topology_stats do |t|

      t.timestamps
    end
  end
end
