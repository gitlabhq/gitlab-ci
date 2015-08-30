# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  timeout                  :integer          default(3600), not null
#  created_at               :datetime
#  updated_at               :datetime
#  token                    :string(255)
#  default_ref              :string(255)
#  path                     :string(255)
#  always_build             :boolean          default(FALSE), not null
#  polling_interval         :integer
#  public                   :boolean          default(FALSE), not null
#  ssh_url_to_repo          :string(255)
#  gitlab_id                :integer
#  allow_git_fetch          :boolean          default(TRUE), not null
#  email_recipients         :string(255)      default(""), not null
#  email_add_pusher         :boolean          default(TRUE), not null
#  email_only_broken_builds :boolean          default(TRUE), not null
#  skip_refs                :string(255)
#  coverage_regex           :string(255)
#  shared_runners_enabled   :boolean          default(FALSE)
#  generated_yaml_config    :text
#

require 'spec_helper'

describe Project do
  subject { FactoryGirl.build :project }

  it { is_expected.to have_many(:commits) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :timeout }
  it { is_expected.to validate_presence_of :default_ref }

  describe 'before_validation' do
    it 'should set an random token if none provided' do
      project = FactoryGirl.create :project_without_token
      expect(project.token).not_to eq ""
    end

    it 'should not set an random toke if one provided' do
      project = FactoryGirl.create :project
      expect(project.token).to eq "iPWx6WM4lhHNedGfBpPJNP"
    end
  end

  describe "ordered_by_last_commit_date" do
    it "returns ordered projects" do
      newest_project = FactoryGirl.create :project
      oldest_project = FactoryGirl.create :project
      project_without_commits = FactoryGirl.create :project

      FactoryGirl.create :commit, committed_at: 1.hour.ago, project: newest_project
      FactoryGirl.create :commit, committed_at: 2.hour.ago, project: oldest_project

      expect(described_class.ordered_by_last_commit_date).to eq [newest_project, oldest_project, project_without_commits]
    end
  end

  context :valid_project do
    let(:project) { FactoryGirl.create :project }

    context :project_with_commit_and_builds do
      before do
        commit = FactoryGirl.create(:commit, project: project)
        FactoryGirl.create(:build, commit: commit)
      end

      it { expect(project.status).to eq 'pending' }
      it { expect(project.last_commit).to be_kind_of(Commit)  }
      it { expect(project.human_status).to eq 'pending' }
    end
  end

  describe '#email_notification?' do
    it do
      project = FactoryGirl.create :project, email_add_pusher: true
      expect(project.email_notification?).to eq true
    end

    it do
      project = FactoryGirl.create :project, email_add_pusher: false, email_recipients: 'test tesft'
      expect(project.email_notification?).to eq true
    end

    it do
      project = FactoryGirl.create :project, email_add_pusher: false, email_recipients: ''
      expect(project.email_notification?).to eq false
    end
  end

  describe '#broken_or_success?' do
    it {
      project = FactoryGirl.create :project, email_add_pusher: true
      allow(project).to receive(:broken?).and_return(true)
      allow(project).to receive(:success?).and_return(true)
      expect(project.broken_or_success?).to eq true
    }

    it {
      project = FactoryGirl.create :project, email_add_pusher: true
      allow(project).to receive(:broken?).and_return(true)
      allow(project).to receive(:success?).and_return(false)
      expect(project.broken_or_success?).to eq true
    }

    it {
      project = FactoryGirl.create :project, email_add_pusher: true
      allow(project).to receive(:broken?).and_return(false)
      allow(project).to receive(:success?).and_return(true)
      expect(project.broken_or_success?).to eq true
    }

    it {
      project = FactoryGirl.create :project, email_add_pusher: true
      allow(project).to receive(:broken?).and_return(false)
      allow(project).to receive(:success?).and_return(false)
      expect(project.broken_or_success?).to eq false
    }
  end

  describe '.parse' do
    let(:project_dump) { YAML.load File.read(Rails.root.join('spec/support/gitlab_stubs/raw_project.yml')) }
    let(:parsed_project) { described_class.parse(project_dump) }

    
    it { expect(parsed_project).to be_valid }
    it { expect(parsed_project).to be_kind_of(described_class) }
    it { expect(parsed_project.name).to eq("GitLab / api.gitlab.org") }
    it { expect(parsed_project.gitlab_id).to eq(189) }
    it { expect(parsed_project.gitlab_url).to eq("http://demo.gitlab.com/gitlab/api-gitlab-org") }

    it "parses plain hash" do
      expect(described_class.parse(project_dump).name).to eq("GitLab / api.gitlab.org")
    end
  end

  describe '#repo_url_with_auth' do
    let(:project) { FactoryGirl.create :project }
    subject { project.repo_url_with_auth }

    it { is_expected.to be_a(String) }
    it { is_expected.to end_with(".git") }
    it { is_expected.to start_with(project.gitlab_url[0..6]) }
    it { is_expected.to include(project.token) }
    it { is_expected.to include('gitlab-ci-token') }
    it { is_expected.to include(project.gitlab_url[7..-1]) }
  end

  describe '.search' do
    let!(:project) { FactoryGirl.create(:project, name: "foo") }

    it { expect(described_class.search('fo')).to include(project) }
    it { expect(described_class.search('bar')).to be_empty }
  end

  describe '#any_runners' do
    it "there are no runners available" do
      project = FactoryGirl.create(:project)
      expect(project.any_runners?).to be_falsey
    end

    it "there is a specific runner" do
      project = FactoryGirl.create(:project)
      project.runners << FactoryGirl.create(:specific_runner)
      expect(project.any_runners?).to be_truthy
    end

    it "there is a shared runner" do
      project = FactoryGirl.create(:project, shared_runners_enabled: true)
      FactoryGirl.create(:shared_runner)
      expect(project.any_runners?).to be_truthy
    end

    it "there is a shared runner, but they are prohibited to use" do
      project = FactoryGirl.create(:project)
      FactoryGirl.create(:shared_runner)
      expect(project.any_runners?).to be_falsey
    end
  end
end
