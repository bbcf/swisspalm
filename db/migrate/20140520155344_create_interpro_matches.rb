class CreateInterproMatches < ActiveRecord::Migration
  def change
    create_table :interpro_matches do |t|

      t.timestamps
    end
  end
end
