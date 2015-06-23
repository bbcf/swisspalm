class CreateCysEnvs < ActiveRecord::Migration
  def change
    create_table :cys_envs do |t|

      t.timestamps
    end
  end
end
