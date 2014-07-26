require 'rails_helper'

describe CreateProjectService do
  let(:service) { CreateProjectService.new }
  let(:current_user) { double.as_null_object }
  let(:project_dump) { File.read(Rails.root.join('spec/support/gitlab_stubs/raw_project.yml')) }

  before { allow_any_instance_of(Network).to receive(:enable_ci).and_return(true) }

  describe :execute do
    context 'valid params' do
      let(:project) { service.execute(current_user, project_dump, 'http://localhost/projects/:project_id') }

      it { expect(project).to be_kind_of(Project) }
      it { expect(project).to be_persisted }
    end

    context 'without project dump' do
      it 'should raise exception' do
        expect { service.execute(current_user, '', '') }.to raise_error
      end
    end
  end
end
