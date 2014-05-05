class CreateWebHook < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.string   "url"
      t.integer  "project_id"
    end
  end
end
