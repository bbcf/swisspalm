class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|

      t.timestamps
    end
  end
end
