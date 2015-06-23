class CreateBlacklistWords < ActiveRecord::Migration
  def change
    create_table :blacklist_words do |t|

      t.timestamps
    end
  end
end
