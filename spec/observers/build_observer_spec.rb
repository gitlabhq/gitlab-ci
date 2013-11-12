require 'spec_helper'

describe BuildObserver do
  subject { BuildObserver.instance }
  before { subject.stub(notification: double('NotificationService').as_null_object) }

  # let(:build) { double(:build).as_null_object }
  let(:build) { FactoryGirl.build(:build, status: 'pending')}

  describe '#after_save' do
    it 'is called after a build is saved' do
      subject.should_receive(:after_save)

      Build.observers.enable :build_observer do
        build.status = :success
        build.save!
      end
    end
    
    it 'sends out notifications when build is a success' do
      subject.should_receive(:notification)

      build.status = :success
      build.save!
      subject.after_save(build)
    end

    it 'sends out notifications when build is a failure' do
      subject.should_receive(:notification)

      build.status = :failed
      build.save!
      subject.after_save(build)
    end

    it 'sends out notifications when build is cancelled' do
      subject.should_receive(:notification)

      build.status = :canceled
      build.save!
      subject.after_save(build)
    end

    it 'does not sends out notifications when build is pending' do
      subject.should_receive(:notification).never

      build.status = :pending
      build.save!
      subject.after_save(build)
    end
  end
end
