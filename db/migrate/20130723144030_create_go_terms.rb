class CreateGoTerms < ActiveRecord::Migration
  def change
    create_table :go_terms do |t|

      t.timestamps
    end
  end
end
