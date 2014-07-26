# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  timeout                  :integer          default(1800), not null
#  scripts                  :text             not null
#  created_at               :datetime
#  updated_at               :datetime
#  token                    :string(255)
#  default_ref              :string(255)
#  gitlab_url               :string(255)
#  always_build             :boolean          default(FALSE), not null
#  polling_interval         :integer
#  public                   :boolean          default(FALSE), not null
#  ssh_url_to_repo          :string(255)
#  gitlab_id                :integer
#  allow_git_fetch          :boolean          default(TRUE), not null
#  email_recipients         :string(255)      default(""), not null
#  email_add_committer      :boolean          default(TRUE), not null
#  email_only_broken_builds :boolean          default(TRUE), not null
#

require 'rails_helper'

describe Project do
  subject { FactoryGirl.build :project }

  it { should have_many(:builds) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :scripts }
  it { should validate_presence_of :timeout }
  it { should validate_presence_of :default_ref }

  describe 'before_validation' do
    it 'should set an random token if none provided' do
      project = FactoryGirl.create :project_without_token
      expect(project.token).not_to eq("")
    end

    it 'should not set an random toke if one provided' do
      project = FactoryGirl.create :project
      expect(project.token).to be == "iPWx6WM4lhHNedGfBpPJNP"
    end
  end

  context :valid_project do
    let(:project) { FactoryGirl.create :project }

    context :project_with_build do
      before { FactoryGirl.create(:build, project: project) }

      it { expect(project.status).to be == 'pending' }
      it { expect(project.last_build).to be_kind_of(Build)  }
      it { expect(project.human_status).to be == 'pending' }
    end
  end

  describe '#email_notification?' do
    it do
      project = FactoryGirl.create :project, email_add_committer: true
      expect(project.email_notification?).to be == true
    end

    it do
      project = FactoryGirl.create :project, email_add_committer: false, email_recipients: 'test tesft'
      expect(project.email_notification?).to be == true
    end

    it do
      project = FactoryGirl.create :project, email_add_committer: false, email_recipients: ''
      expect(project.email_notification?).to be == false
    end
  end

  describe '#broken_or_success?' do
    it {
      project = FactoryGirl.create :project, email_add_committer: true
      allow(project).to receive(:broken?).and_return(true)
      allow(project).to receive(:success?).and_return(true)
      expect(project.broken_or_success?).to be == true
    }

    it {
      project = FactoryGirl.create :project, email_add_committer: true
      allow(project).to receive(:broken?).and_return(true)
      allow(project).to receive(:success?).and_return(false)
      expect(project.broken_or_success?).to be == true
    }

    it {
      project = FactoryGirl.create :project, email_add_committer: true
      allow(project).to receive(:broken?).and_return(false)
      allow(project).to receive(:success?).and_return(true)
      expect(project.broken_or_success?).to be == true
    }

    it {
      project = FactoryGirl.create :project, email_add_committer: true
      allow(project).to receive(:broken?).and_return(false)
      allow(project).to receive(:success?).and_return(false)
      expect(project.broken_or_success?).to be == false
    }
  end

  describe 'Project.parse' do
    let(:project_dump) { File.read(Rails.root.join('spec/support/gitlab_stubs/raw_project.yml')) }
    let(:parsed_project) { Project.parse(project_dump) }

    it { expect(parsed_project).to be_valid }
    it { expect(parsed_project).to be_kind_of(Project) }
    it { expect(parsed_project.name).to eq("GitLab / api.gitlab.org") }
    it { expect(parsed_project.gitlab_id).to eq(189) }
    it { expect(parsed_project.gitlab_url).to eq("http://localhost:3000/gitlab/api-gitlab-org") }
  end
end

# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  name                      :string(255)      not null
#  timeout                   :integer          default(1800), not null
#  scripts                   :text             default(""), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  token                     :string(255)
#  default_ref               :string(255)
#  gitlab_url                :string(255)
#  always_build              :boolean          default(FALSE), not null
#  polling_interval          :integer
#  public                    :boolean          default(FALSE), not null
#  ssh_url_to_repo           :string(255)
#  gitlab_id                 :integer
#  allow_git_fetch           :boolean          default(TRUE), not null
#  email_recipients          :string(255)
#  email_add_committer       :boolean          default(TRUE), not null
#  email_only_breaking_build :boolean          default(TRUE), not null
#

