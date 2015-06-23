class CreateTmpWords < ActiveRecord::Migration
  def change
    create_table :tmp_words do |t|

      t.timestamps
    end
  end
end
