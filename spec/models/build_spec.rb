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

  context "#previous_build_status" do
    let(:p1) { FactoryGirl.create(:project, name: 'p1') }
    let(:p2) { FactoryGirl.create(:project, name: 'p2') }

    let!(:b1) { FactoryGirl.create(:build, project: p1, ref: 'master', status: "success") }
    let!(:b2) { FactoryGirl.create(:build, project: p1, ref: 'master', status: "failed") }
    let!(:b3) { FactoryGirl.create(:build, project: p1, ref: 'master', status: 'canceled') }
    let!(:b4) { FactoryGirl.create(:build, project: p1, ref: 'fixes') }

    let!(:b5) { FactoryGirl.create(:build, project: p2, ref: 'master') }

    it "return previous build status with same project and ref" do
      b1.previous_build_status.should be_nil
      b2.previous_build_status.should == 'success'
      b3.previous_build_status.should == 'failed'
      b4.previous_build_status.should be_nil
    end
  end
end



# == Schema Information
#
# Table name: builds
#
#  id          :integer(4)      not null, primary key
#  project_id  :integer(4)
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text(2147483647
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#

