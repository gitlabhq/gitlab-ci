require 'spec_helper'

describe CreateCommitService do
  let(:service) { CreateCommitService.new }
  let(:project) { FactoryGirl.create(:project) }

  describe :execute do
    context 'valid params' do
      let(:commit) { service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') }

      it { commit.should be_kind_of(Commit) }
      it { commit.should be_valid }
      it { commit.should be_persisted }
      it { commit.should == project.commits.last }
      it { commit.builds.first.should be_kind_of(Build) }
    end

    context 'without params' do
      subject { service.execute(project, {}) }

      it { should be_false }
    end

    context "deploy builds" do
      it "calls create_deploy_builds if there are no builds" do
        project.jobs.destroy_all
        Commit.any_instance.should_receive(:create_deploy_builds)
        service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312')
      end

      it "does not call create_deploy_builds if there is build" do
        Commit.any_instance.should_not_receive(:create_deploy_builds)
        service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312')
      end
    end

    context "skip tag if there is no build for it" do
      it "does not create commit if there is no appropriate job" do
        project.jobs

        result = service.execute(project, ref: 'refs/tags/0_1', before: '00000000', after: '31das312')
        result.should be_false
      end

      it "creates commit if there is appropriate job" do
        project.jobs.first.update(build_tags: true)

        result = service.execute(project, ref: 'refs/tags/0_1', before: '00000000', after: '31das312')
        result.should be_persisted
      end

      it "does not create commit if there is no appropriate job nor deploy job" do
        project.jobs.first.update(build_tags: false)
        FactoryGirl.create(:deploy_job, project: project, refs: "release")

        result = service.execute(project, ref: 'refs/tags/0_1', before: '00000000', after: '31das312')
        result.should be_false
      end

      it "creates commit if there is no appropriate job but deploy job has right ref setting" do
        project.jobs.first.update(build_tags: false)
        FactoryGirl.create(:deploy_job, project: project, refs: "0_1")

        result = service.execute(project, ref: 'refs/tags/0_1', before: '00000000', after: '31das312')
        result.should be_persisted
      end

      it "creates commit if there is no appropriate job and deploy job has no ref setting" do
        project.jobs.first.update(build_tags: true)
        FactoryGirl.create(:deploy_job, project: project)

        result = service.execute(project, ref: 'refs/tags/0_1', before: '00000000', after: '31das312')
        result.should be_persisted
      end
    end
  end
end
