class ReportFileContentTypeToBinary < ActiveRecord::Migration
  def up
    change_column :report_file_contents, :content, :binary, :limit => 10.megabyte
  end

  def down
    change_column :report_file_contents, :content, :string
  end
end
