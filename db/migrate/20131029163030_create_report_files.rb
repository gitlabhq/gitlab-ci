class CreateReportFiles < ActiveRecord::Migration
  def change
    create_table :report_files do |t|
      t.string :filename
      t.string :filetype
      t.references :project

      t.timestamps
    end

  end
end
