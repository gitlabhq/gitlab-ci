class TestReportsAreNested < ActiveRecord::Migration
  def up
    add_column :test_reports, :parent_id, :integer
    add_column :test_reports, :lft, :integer
    add_column :test_reports, :rgt, :integer
  end

  def down
  end
end
