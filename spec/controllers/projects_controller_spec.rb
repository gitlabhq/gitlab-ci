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
      expect(response.code).to eq('200')
    end

    it 'should respond 200 if push about removed branch' do
      post :build, id: @project.id,
        ref: 'master',
        before: '2aa371379db71ac89ae20843fcff3b3477cf1a1d',
        after: '000000000000000000000000000000000000000',
        token: @project.token

      expect(response).to be_success
      expect(response.code).to eq('200')
    end

    it 'should respond 500 if something wrong' do
      post :build, id: @project.id, token: @project.token
      expect(response).not_to be_success
      expect(response.code).to eq('500')
    end

    it 'should respond 403 if token is wrong' do
      post :build, id: @project.id, token: 'invalid-token'
      expect(response).not_to be_success
      expect(response.code).to eq('403')
    end
  end
end
