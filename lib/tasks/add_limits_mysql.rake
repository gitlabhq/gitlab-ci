desc "GitLab | Add limits to strings in mysql database"
task add_limits_mysql: :environment do
  puts "Adding limits to schema.rb for mysql"
  LimitsToMysql.new.up
end

class LimitsToMysql < ActiveRecord::Migration
  def up
    return unless ActiveRecord::Base.configurations[Rails.env]['adapter'] =~ /^mysql/

    change_column :builds, :trace, :text, limit: 2147483647
    change_column :builds, :push_data, :text, limit: 2147483647
  end
end
