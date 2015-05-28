require 'spec_helper'

describe SlackMessage do
  subject { SlackMessage.new(commit) }

  let(:project) { FactoryGirl.create :project }
  let(:commit)  { FactoryGirl.create :commit, project: project }
  let(:job)     { FactoryGirl.create :job, project: project }
  let(:build)   { FactoryGirl.create :build, commit: commit, job: job, status: 'success' }

  context 'when build succeeded' do
    let(:color) { 'good' }

    before { build }

    it 'returns a message with succeeded build' do
      subject.color.should == color
      subject.fallback.should include('Build')
      subject.fallback.should include("\##{build.id}")
      subject.fallback.should include('succeeded')
      subject.attachments.first[:fields].should be_empty
    end
  end

  context 'when build failed' do
    let(:color) { 'danger' }

    before do
      build.status = 'failed'
      build.save
    end

    it 'returns a message with failed build' do
      subject.color.should == color
      subject.fallback.should include('Build')
      subject.fallback.should include("\##{build.id}")
      subject.fallback.should include('failed')
      subject.attachments.first[:fields].should be_empty
    end
  end

  context 'when all matrix builds succeeded' do
    let(:job2)     { FactoryGirl.create :job, project: project }
    let(:build2)   { FactoryGirl.create :build, commit: commit, job: job2, status: 'success' }
    let(:color)    { 'good' }

    before { build; build2 }

    it 'returns a message with success' do
      subject.color.should == color
      subject.fallback.should include('Commit')
      subject.fallback.should include("\##{commit.id}")
      subject.fallback.should include('succeeded')
      subject.attachments.first[:fields].should be_empty
    end
  end

  context 'when one of matrix builds failed' do
    let(:job2)     { FactoryGirl.create :job, project: project, name: 'Test JOB' }
    let(:build2)   { FactoryGirl.create :build, id: 10, commit: commit, job: job2, status: 'success' }
    let(:color)    { 'danger' }

    before do
      build
      build2.status = 'failed'
      build2.save
    end

    it 'returns a message with information about failed build' do
      subject.color.should == color
      subject.fallback.should include('Commit')
      subject.fallback.should include("\##{commit.id}")
      subject.fallback.should include('failed')
      subject.attachments.first[:fields].size.should == 1
      subject.attachments.first[:fields].first[:title].should == build2.name
      subject.attachments.first[:fields].first[:value].should include("\##{build2.id}")
    end
  end
end
