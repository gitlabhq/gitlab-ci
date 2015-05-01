require 'spec_helper'

describe HipChatMessage do
  subject { HipChatMessage.new(build) }

  let(:project) { FactoryGirl.create(:project) }
  let(:commit)  { FactoryGirl.create(:commit, project: project) }
  let(:job)     { FactoryGirl.create(:job, project: project) }
  let(:build)   { FactoryGirl.create(:build, commit: commit, job: job, status: 'success') }

  context 'when build succeeds' do

    before { build.save }

    it 'returns a successful message' do
      expect( subject.status_color ).to eq 'green'
      expect( subject.notify? ).to be_false
      expect( subject.to_s ).to match(/Build '[^']+' #\d+/)
      expect( subject.to_s ).to match(/Successful in \d+ second\(s\)\./)
    end
  end

  context 'when build fails' do

    before do
      build.status = 'failed'
      build.save
    end

    it 'returns a failure message' do
      expect( subject.status_color ).to eq 'red'
      expect( subject.notify? ).to be_true
      expect( subject.to_s ).to match(/Build '[^']+' #\d+/)
      expect( subject.to_s ).to match(/Failed in \d+ second\(s\)\./)
    end
  end

  context 'when all matrix builds succeed' do
    let(:job2)    { FactoryGirl.create(:job, project: project, name: 'Another Job') }
    let(:build2)  { FactoryGirl.create(:build, id: 10, commit: commit, job: job2, status: 'success') }

    before { build.save; build2.save }

    it 'returns a successful message' do
      expect( subject.status_color ).to eq 'green'
      expect( subject.notify? ).to be_false
      expect( subject.to_s ).to match(/Commit #\d+/)
      expect( subject.to_s ).to match(/Successful in \d+ second\(s\)\./)
    end
  end

  context 'when at least one matrix build fails' do
    let(:job2)    { FactoryGirl.create(:job, project: project, name: 'Another Job') }
    let(:build2)  { FactoryGirl.create(:build, id: 10, commit: commit, job: job2, status: 'failed') }

    before { build.save; build2.save }

    it 'returns a failure message' do
      expect( subject.status_color ).to eq 'red'
      expect( subject.notify? ).to be_true
      expect( subject.to_s ).to match(/Commit #\d+/)
      expect( subject.to_s ).to match(/Failed in \d+ second\(s\)\./)
    end
  end
end
