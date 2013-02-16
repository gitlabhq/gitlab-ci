class CreateUserOauthAccount < ActiveRecord::Migration
  def change
    create_table :user_oauth_accounts do |t|
      t.string  :provider
      t.string  :uid
      t.integer :user_id
      t.string  :token
      t.string  :secret
      t.string  :name
      t.string  :link
      t.timestamps
    end
  end
end
