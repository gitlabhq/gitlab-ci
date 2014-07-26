# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime
#  updated_at  :datetime
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  runner_id   :integer
#

require 'rails_helper'

describe Build do
  let(:project) { FactoryGirl.create :project }
  let(:build) { FactoryGirl.create :build }
  let(:build_with_project) { FactoryGirl.create :build, project: project }

  it { should belong_to(:project) }
  it { should validate_presence_of :before_sha }
  it { should validate_presence_of :sha }
  it { should validate_presence_of :ref }
  it { should validate_presence_of :status }

  it { should respond_to :success? }
  it { should respond_to :failed? }
  it { should respond_to :running? }
  it { should respond_to :pending? }
  it { should respond_to :git_author_name }
  it { should respond_to :git_author_email }
  it { should respond_to :short_sha }
  it { should respond_to :trace_html }

  it { should allow_mass_assignment_of(:project_id) }
  it { should allow_mass_assignment_of(:ref) }
  it { should allow_mass_assignment_of(:sha) }
  it { should allow_mass_assignment_of(:before_sha) }
  it { should allow_mass_assignment_of(:status) }
  it { should allow_mass_assignment_of(:finished_at) }
  it { should allow_mass_assignment_of(:trace) }
  it { should allow_mass_assignment_of(:started_at) }
  it { should allow_mass_assignment_of(:push_data) }
  it { should allow_mass_assignment_of(:runner_id) }
  it { should allow_mass_assignment_of(:project_name) }

  describe :first_pending do
    let(:first) { FactoryGirl.create :build, status: 'pending', created_at: Date.yesterday }
    let(:second) { FactoryGirl.create :build, status: 'pending' }
    before { first; second }
    subject { Build.first_pending }

    it { should be_a(Build) }
    it('returns with the first pending build') { should eq(first) }
  end

  describe :create_from do
    before do
      build.status = 'success'
      build.save
    end
    let(:create_from_build) { Build.create_from build }

    it ('there should be a pending task') do
      expect(Build.pending.count).to eq(0)
      create_from_build
      expect(Build.pending.count).to be > 0
    end
  end

  describe :ci_skip? do
    let(:project) { FactoryGirl.create(:project) }
    let(:build) { FactoryGirl.create(:build, project: project) }

    it 'true if commit message contains [ci skip]' do
      allow(build).to receive(:git_commit_message) { 'Small typo [ci skip]' }
      expect(build.ci_skip?).to be == true
    end

    it 'false if commit message does not contain [ci skip]' do
      expect(build.ci_skip?).to be == false
    end
  end

  describe :project_recipients do

    context 'always sending notification' do
      it 'should return git_author_email as only recipient when no additional recipients are given' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: ''
        build =  FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        allow(build).to receive(:git_author_email) { expected }
        expect(build.project_recipients).to be == [expected]
      end

      it 'should return git_author_email and additional recipients' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: 'rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        allow(build).to receive(:git_author_email) { expected }
        expect(build.project_recipients).to be == ['rec1', 'rec2', expected]
      end

      it 'should return recipients' do
        project = FactoryGirl.create :project,
          email_add_committer: false,
          email_recipients: 'rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        allow(build).to receive(:git_author_email) { expected }
        expect(build.project_recipients).to be == ['rec1', 'rec2']
      end

      it 'should return unique recipients only' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: 'rec1 rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'rec2'
        allow(build).to receive(:git_author_email) { expected }
        expect(build.project_recipients).to be == ['rec1', 'rec2']
      end
    end
  end

  describe :started? do
    subject { build.started? }

    context 'without started_at' do
      before { build.started_at = nil }

      it { should be_falsey }
    end

    %w(running success failed).each do |status|
      context "if build status is #{status}" do
        before { build.status = status }

        it { should be_truthy }
      end
    end

    %w(pending canceled).each do |status|
      context "if build status is #{status}" do
        before { build.status = status }

        it { should be_falsey }
      end
    end
  end

  describe :active? do
    subject { build.active? }

    %w(pending running).each do |state|
      context "if build.status is #{state}" do
        before { build.status = state }

        it { should be_truthy }
      end
    end

    %w(success failed canceled).each do |state|
      context "if build.status is #{state}" do
        before { build.status = state }

        it { should be_falsey }
      end
    end
  end

  describe :complete? do
    subject { build.complete? }

    %w(success failed canceled).each do |state|
      context "if build.status is #{state}" do
        before { build.status = state }

        it { should be_truthy }
      end
    end

    %w(pending running).each do |state|
      context "if build.status is #{state}" do
        before { build.status = state }

        it { should be_falsey }
      end
    end
  end

  describe :valid_commit_sha do
    context 'build.sha can not start with 00000000' do
      before do
        build.sha = '0' * 32
        build.valid_commit_sha
      end

      it('build errors should not be empty') { expect(build.errors).not_to be_empty }
    end
  end

  describe :trace do
    subject { build.trace_html }

    it { should be_empty }

    context 'if build.trace contains text' do
      let(:text) { 'example output' }
      before { build.trace = text }

      it { should include(text) }
      it { expect(subject.length).to be >= text.length }
    end
  end

  describe :compare? do
    subject { build_with_project.compare? }

    context 'if project.gitlab_url and build.before_sha are not nil' do
      it { should be_truthy }
    end
  end

  describe :short_sha do
    subject { build.short_before_sha }

    it { expect(subject.length).to be(9) }
    it { expect(build.before_sha).to start_with(subject) }
  end

  describe :short_sha do
    subject { build.short_sha }

    it { expect(subject.length).to be(9) }
    it { expect(build.sha).to start_with(subject) }
  end

  describe :repo_url do
    subject { build_with_project.repo_url }

    it { should be_a(String) }
    it { should end_with(".git") }
    it { should start_with(project.gitlab_url[0..6]) }
    it { should include(project.token) }
    it { should include('gitlab-ci-token') }
    it { should include(project.gitlab_url[7..-1]) }
  end

  describe :gitlab? do
    subject { build_with_project.gitlab? }

    it { should eq(project.gitlab?) }
  end

  describe :commands do
    subject { build_with_project.commands }

    it { should eq(project.scripts) }
  end

  describe :timeout do
    subject { build_with_project.timeout }

    it { should eq(project.timeout) }
  end

  describe :allow_git_fetch do
    subject { build_with_project.allow_git_fetch }

    it { should eq(project.allow_git_fetch) }
  end

  describe :name do
    subject { build_with_project.project_name }

    it { should eq(project.name) }
  end

  describe :duration do
    subject { build.duration }

    it { should eq(120.0) }

    context 'if the building process has not started yet' do
      before do
        build.started_at = nil
        build.finished_at = nil
      end

      it { should be_nil }
    end

    context 'if the building process has started' do
      before do
        build.started_at = Time.now - 1.minute
        build.finished_at = nil
      end

      it { should be_a(Float) }
      it { should > 0.0 }
    end
  end
end
