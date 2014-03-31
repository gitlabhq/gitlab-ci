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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  runner_id   :integer
#

require 'spec_helper'

describe Build do
  subject { Build.new }

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

  describe "#ci_skip?" do
    let(:project) { FactoryGirl.create(:project) }
    let(:build) { FactoryGirl.create(:build, project: project) }

    it 'true if commit message contains [ci skip]' do
      build.stub(:git_commit_message) { 'Small typo [ci skip]' }
      build.ci_skip?.should == true
    end

    it 'false if commit message does not contain [ci skip]' do
      build.ci_skip?.should == false
    end
  end

  describe '#project_recipients' do

    context 'always sending notification' do
      it 'should return git_author_email as only recipient when no additional recipients are given' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: ''
        build =  FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        build.stub(:git_author_email) { expected }
        build.project_recipients.should == [expected]
      end

      it 'should return git_author_email and additional recipients' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: 'rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        build.stub(:git_author_email) { expected }
        build.project_recipients.should == ['rec1', 'rec2', expected]
      end

      it 'should return recipients' do
        project = FactoryGirl.create :project,
          email_add_committer: false,
          email_recipients: 'rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'git_author_email'
        build.stub(:git_author_email) { expected }
        build.project_recipients.should == ['rec1', 'rec2']
      end

      it 'should return unique recipients only' do
        project = FactoryGirl.create :project,
          email_add_committer: true,
          email_recipients: 'rec1 rec1 rec2'
        build = FactoryGirl.create :build,
          status: :success,
          project: project
        expected = 'rec2'
        build.stub(:git_author_email) { expected }
        build.project_recipients.should == ['rec1', 'rec2']
      end
    end
  end
end
