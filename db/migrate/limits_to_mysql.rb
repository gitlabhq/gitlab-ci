class LimitsToMysql < ActiveRecord::Migration
  def up
    return unless ActiveRecord::Base.configurations[Rails.env]['adapter'] =~ /^mysql/

    change_column :builds, :trace, :text, limit: 1073741823
    change_column :commits, :push_data, :text, limit: 16777215
  end
end
