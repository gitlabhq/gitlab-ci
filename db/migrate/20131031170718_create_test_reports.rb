class CreateTestReports < ActiveRecord::Migration
  def change
    create_table :test_reports do |t|
      t.string :testClass
      t.string :title
      t.string :description
      t.float :duration
      t.text :status
      t.text :location
      t.text :error_message
      t.references :build

      t.timestamps
    end
  end
end
