require 'spec_helper'

describe BuildObserver do
  subject { BuildObserver.instance }
  before { subject.stub(notification: double('NotificationService').as_null_object) }

  describe '#after_save' do
    
    context "only one build per project" do
      let(:project) { FactoryGirl.build(:project) }
      let(:build) { FactoryGirl.build(:build, status: 'success', project: project)}
    
      it 'is called after a build is saved' do
        subject.should_receive(:after_save)
  
        Build.observers.enable :build_observer do
          build.status = :success
          build.save!
        end
      end
      
      describe "sends out notification" do
        it 'is a failure' do
          subject.should_receive(:notification)
          build.status = :failed
          build.save!
          subject.after_save(build)
        end
    
        it 'is cancelled' do
          subject.should_receive(:notification)
          build.status = :canceled
          build.save!
          subject.after_save(build)
        end
      end
    
      describe "sends no notification" do
        it 'is a success' do
          subject.should_not_receive(:notification)
          build.status = :success
          build.save!
          subject.after_save(build)
        end
      
        it "sends no notification when status is pending" do
          subject.should_not_receive(:notification)
          build.status = :pending
          build.save!
          subject.after_save(build)
        end
      end
    end
    
    context "more than 1 build per project" do
      let!(:project) { FactoryGirl.build(:project) }
      let(:build) { FactoryGirl.build(:build, project: project)}
    
      before { project.stub(:email_notification?).and_return(true) }
      
      describe "sends out notification" do
        it 'is a failure and all broken builds should send an email' do
          subject.should_receive(:notification)
          project.stub(:broken?).and_return(true)
          project.stub(:email_all_broken_builds?).and_return(true)
          subject.after_save(build)
        end
    
        it 'is build status success but changed sinced last build' do
          subject.should_receive(:notification)
          project.stub(:broken?).and_return(false)
          project.stub(:last_build_changed_status?).and_return(true)
          subject.after_save(build)
        end

        it 'is build status broken but changed sinced last build' do
          subject.should_receive(:notification)
          project.stub(:broken?).and_return(true)
          project.stub(:last_build_changed_status).and_return(true)
          subject.after_save(build)
        end
      end
    
      describe "sends no notification" do
        it 'is build status broken but not changed sinced last build' do
          subject.should_not_receive(:notification)
          project.stub(:broken?).and_return(true)
          project.stub(:email_all_broken_builds?).and_return(false)
          project.stub(:last_build_changed_status?).and_return(false)
          subject.after_save(build)
        end
      
        it 'is build status success but not changed sinced last build' do
          subject.should_not_receive(:notification)
          project.stub(:broken?).and_return(false)
          project.stub(:email_all_broken_builds?).and_return(false)
          project.stub(:last_build_changed_status?).and_return(false)
          subject.after_save(build)
        end
      end
      
    end
  end
end
