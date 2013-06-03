# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text(2147483647)
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
  it { should validate_presence_of :sha }
  it { should validate_presence_of :ref }
  it { should validate_presence_of :status }

  it { should respond_to :success? }
  it { should respond_to :failed? }
  it { should respond_to :running? }
  it { should respond_to :pending? }
  it { should respond_to :git_author_name }
  it { should respond_to :short_sha }
  it { should respond_to :trace_html }

  describe "#ci_skip?" do
    let(:project) { FactoryGirl.create(:project) }
    let(:build) { project.register_build(ref: 'master') }

    it 'true if commit message contains [ci skip]' do
      build.stub(:git_commit_message) { 'Small typo [ci skip]' }
      build.ci_skip?.should == true
    end

    it 'false if commit message does not contain [ci skip]' do
      build.ci_skip?.should == false
    end
  end
end


