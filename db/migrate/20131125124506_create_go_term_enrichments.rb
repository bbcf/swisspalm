class CreateGoTermEnrichments < ActiveRecord::Migration
  def change
    create_table :go_term_enrichments do |t|

      t.timestamps
    end
  end
end
