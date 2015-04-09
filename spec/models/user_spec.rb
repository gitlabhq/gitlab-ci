require 'spec_helper'

describe User do

  describe "has_developer_access?" do
    before do
      @user = User.new({})
    end

    let(:project_with_owner_access) do
      {
        "name" => "gitlab-shell",
        "permissions" => {
          "project_access" => {
            "access_level"=> 10,
            "notification_level" => 3
          },
          "group_access" => {
            "access_level" => 50,
            "notification_level" => 3
          }
        }
      }
    end

    let(:project_with_reporter_access) do
      {
        "name" => "gitlab-shell",
        "permissions" => {
          "project_access" => {
            "access_level" => 20,
            "notification_level" => 3
          },
          "group_access" => {
            "access_level" => 10,
            "notification_level" => 3
          }
        }
      }
    end

    it "returns false for reporter" do
      @user.stub(:project_info).and_return(project_with_reporter_access)

      @user.has_developer_access?(1).should be_false
    end

    it "returns true for owner" do
      @user.stub(:project_info).and_return(project_with_owner_access)

      @user.has_developer_access?(1).should be_true
    end
  end
end
