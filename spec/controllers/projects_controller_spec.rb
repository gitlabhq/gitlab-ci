require "spec_helper"

describe ProjectsController do
  before do
    @project = FactoryGirl.create :project
  end

  describe "POST #build" do
    it 'should respond 200 if params is ok' do
      post :build, id: @project.id,
        ref: 'master',
        before: '2aa371379db71ac89ae20843fcff3b3477cf1a1d',
        after: '1c8a9df454ef68c22c2a33cca8232bb50849e5c5',
        token: @project.token


      expect(response).to be_success
      expect(response.code).to eq('201')
    end

    it 'should respond 400 if push about removed branch' do
      post :build, id: @project.id,
        ref: 'master',
        before: '2aa371379db71ac89ae20843fcff3b3477cf1a1d',
        after: '0000000000000000000000000000000000000000',
        token: @project.token

      expect(response).not_to be_success
      expect(response.code).to eq('400')
    end

    it 'should respond 400 if some params missed' do
      post :build, id: @project.id, token: @project.token
      expect(response).not_to be_success
      expect(response.code).to eq('400')
    end

    it 'should respond 403 if token is wrong' do
      post :build, id: @project.id, token: 'invalid-token'
      expect(response).not_to be_success
      expect(response.code).to eq('403')
    end

    describe "POST /:projects" do
      let(:project_dump) { File.read(Rails.root.join('spec/support/gitlab_stubs/raw_project.yml')) }
      let(:gitlab_url) { GitlabCi.config.gitlab_server.url }

      let (:user_data) do
        data = JSON.parse File.read(Rails.root.join('spec/support/gitlab_stubs/user.json'))
        data.merge("url" => gitlab_url)
      end

      let(:user) do
        User.new(user_data)
      end

      it "creates project" do
        allow(controller).to receive(:reset_cache) { true }
        allow(controller).to receive(:current_user) { user }
        Network.any_instance.stub(:enable_ci).and_return(true)

        post :create, { project: project_dump }.with_indifferent_access

        Project.exists?(gitlab_id: 189).should be_true
        expect(response.code).to eq('302')
      end
    end
  end
end
