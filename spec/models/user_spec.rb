require 'spec_helper'

describe User do

  describe "has_developer_access?" do
    before do
      @user = described_class.new({})
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
      allow(@user).to receive(:project_info).and_return(project_with_reporter_access)

      @user.has_developer_access?(1).should be_falsey
    end

    it "returns true for owner" do
      allow(@user).to receive(:project_info).and_return(project_with_owner_access)

      @user.has_developer_access?(1).should be_truthy
    end
  end

  describe "authorized_projects" do
    let (:user) { described_class.new({}) }

    before do
      FactoryGirl.create :project, gitlab_id: 1
      FactoryGirl.create :project, gitlab_id: 2
      gitlab_project = OpenStruct.new({id: 1})
      gitlab_project1 = OpenStruct.new({id: 2})
      allow_any_instance_of(described_class).to receive(:gitlab_projects).and_return([gitlab_project, gitlab_project1])
    end

    it "returns projects" do
      allow_any_instance_of(described_class).to receive(:can_manage_project?).and_return(true)

      user.authorized_projects.count.should eq 2
    end

    it "empty list if user miss manage permission" do
      allow_any_instance_of(described_class).to receive(:can_manage_project?).and_return(false)

      user.authorized_projects.count.should eq 0
    end
  end

  describe "authorized_runners" do
    it "returns authorized runners" do
      project = FactoryGirl.create :project, gitlab_id: 1
      project1 = FactoryGirl.create :project, gitlab_id: 2
      gitlab_project = OpenStruct.new({id: 1})
      gitlab_project1 = OpenStruct.new({id: 2})
      allow_any_instance_of(described_class).to receive(:gitlab_projects).and_return([gitlab_project, gitlab_project1])
      allow_any_instance_of(described_class).to receive(:can_manage_project?).and_return(true)
      user = described_class.new({})

      runner = FactoryGirl.create :specific_runner
      runner1 = FactoryGirl.create :specific_runner
      runner2 = FactoryGirl.create :specific_runner

      project.runners << runner
      project1.runners << runner1

      user.authorized_runners.should include(runner, runner1)
      user.authorized_runners.should_not include(runner2)
    end
  end
end
