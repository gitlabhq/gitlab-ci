require 'spec_helper'

describe CreateProjectService do
  let(:service) { CreateProjectService.new }
  let(:current_user) { double.as_null_object }
  let(:project_dump) { File.read(Rails.root.join('spec/support/gitlab_stubs/raw_project.yml')) }

  before { Network.any_instance.stub(enable_ci: true) }

  describe :execute do
    context 'valid params' do
      let(:project) { service.execute(current_user, project_dump, 'http://localhost/projects/:project_id') }

      it { project.should be_kind_of(Project) }
      it { project.should be_persisted }
    end

    context 'without project dump' do
      it 'should raise exception' do
        expect { service.execute(current_user, '', '') }.to raise_error
      end
    end
  end
end
