require 'spec_helper'

describe UserOauthAccount do
  context ".register_user!" do
    let(:auth_hash) { {
      uid: 123,
      credentials: {
        token: "token"
      },
      info: {
        nickname: 'nickname'
      }
    } }
    it "should create a new user by credentials" do
      expect {
        described_class.register_user!('github', auth_hash)
      }.to change{ User.count }.by(1)
    end
  end
end

# == Schema Information
#
# Table name: user_oauth_accounts
#
#  id         :integer(4)      not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  user_id    :integer(4)
#  token      :string(255)
#  secret     :string(255)
#  name       :string(255)
#  link       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

