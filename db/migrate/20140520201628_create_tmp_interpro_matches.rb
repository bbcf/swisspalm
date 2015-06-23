class CreateTmpInterproMatches < ActiveRecord::Migration
  def change
    create_table :tmp_interpro_matches do |t|

      t.timestamps
    end
  end
end
