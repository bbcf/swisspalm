class CreateVerbs < ActiveRecord::Migration
  def change
    create_table :verbs do |t|

      t.timestamps
    end
  end
end
