class AddWebhooksToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :webhooks, :text
  end
end
