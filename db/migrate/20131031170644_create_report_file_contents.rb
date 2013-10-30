class CreateReportFileContents < ActiveRecord::Migration
  def change
    create_table :report_file_contents do |t|
      t.string :content
      t.references :build
      t.references :report_file
    end

  end
end
