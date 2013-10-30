class CreateCoverages < ActiveRecord::Migration
  def change
    create_table :coverages do |t|
      t.string :file
      t.string :lines
      t.float :percentage
      t.references :build

      t.timestamps
    end
  end
end
