require "spec_helper"
require "chunky_png"

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

  describe "GET #status" do
    describe "with build" do
      before do
        @project = FactoryGirl.create :project, { name: "build" }
        @build = FactoryGirl.create :build, project: @project, status: "success"
      end

      it 'should respond to json format' do
        get "status", { id: @project.id, format: "json" }
        expect(response.body).to eq(@build.to_json)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: @build.sha, format: "json" }
        expect(response.body).to eq(@build.to_json)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: @build.ref, format: "json" }
        expect(response.body).to eq(@build.to_json)
        expect(response.code).to eq('200')
      end

      it 'should respond to xml format' do
        get "status", { id: @project.id, format: "xml" }
        expect(response.body).to eq(@build.to_xml)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: @build.sha, format: "xml" }
        expect(response.body).to eq(@build.to_xml)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: @build.ref, format: "xml" }
        expect(response.body).to eq(@build.to_xml)
        expect(response.code).to eq('200')
      end

      it 'should respond to png (default) format' do
        get "status", { id: @project.id, format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('success.png')
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: @build.sha, format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('success.png')
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: @build.ref, format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('success.png')
        expect(response.code).to eq('200')
      end
    end

    describe "without build" do
      before do
        @project = FactoryGirl.create :project, { name: "no build" }
      end

      it 'should respond to json format' do
        get "status", { id: @project.id, format: "json" }
        unknown_json = '{"status":"unknown"}'
        expect(response.body).to eq(unknown_json)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: "bad sha", format: "json" }
        expect(response.body).to eq(unknown_json)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: "bad ref", format: "json" }
        expect(response.body).to eq(unknown_json)
        expect(response.code).to eq('200')
      end

      it 'should respond to xml format' do
        unknown_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <status>unknown</status>\n</hash>\n"
        get "status", { id: @project.id, id: @project.id, format: "xml" }
        expect(response.body).to eq(unknown_xml)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: "bad sha", format: "xml" }
        expect(response.body).to eq(unknown_xml)
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: "bad ref", format: "xml" }
        expect(response.body).to eq(unknown_xml)
        expect(response.code).to eq('200')
      end

      it 'should respond to png (default) format' do
        get "status", { id: @project.id, id: @project.id, format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('unknown.png')
        expect(response.code).to eq('200')

        get "status", { id: @project.id, sha: "bad sha", format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('unknown.png')
        expect(response.code).to eq('200')

        get "status", { id: @project.id, ref: "bad ref", format: "png" }
        lambda { ChunkyPNG::Image.from_blob(response.body) }.should_not raise_error
        expect(response.header["Content-Type"]).to eq("image/png")
        expect(File.basename(response.to_path)).to eq('unknown.png')
        expect(response.code).to eq('200')
      end
    end
  end
end
