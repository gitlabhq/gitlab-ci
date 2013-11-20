class AddEmailNotificationFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :email_recipients, :string, default: '', null: false
    add_column :projects, :email_add_committer, :boolean, default: true, null: false
    add_column :projects, :email_only_breaking_build, :boolean, default: true, null: false
  end
end
