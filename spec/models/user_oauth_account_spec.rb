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
