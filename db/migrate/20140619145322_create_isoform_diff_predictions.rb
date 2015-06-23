class CreateIsoformDiffPredictions < ActiveRecord::Migration
  def change
    create_table :isoform_diff_predictions do |t|

      t.timestamps
    end
  end
end
