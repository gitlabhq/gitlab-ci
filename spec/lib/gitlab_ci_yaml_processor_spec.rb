require 'spec_helper'

describe GitlabCiYamlProcessor do
  
  describe "#builds" do
    it "returns builds from string" do
      config = YAML.dump({
        jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds.size.should == 1
      config_processor.builds.first.should == {
        branches: true,
        commands: "\nls",
        name: "ls",
        tag_list: "",
        tags: nil
      }
    end

    it "returns builds from string including before_script" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds.first.should == {
        branches: true,
        commands: "pwd\nls",
        name: "ls",
        tag_list: "",
        tags: nil
      }
    end

    it "returns builds from job hash" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: [{script: "ls", name: "Rspec", runner: "mysql,ruby"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds.first.should == {
        branches: true,
        commands: "pwd\nls",
        name: "Rspec",
        tag_list: "mysql,ruby",
        tags: nil
      }
    end
  end

  describe "#deploy_builds" do
    it "returns deploy builds from string" do
      config = YAML.dump({
        deploy_jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds.size.should == 1
      config_processor.deploy_builds.first.should == {
        commands: "\nls",
        name: "ls",
        deploy: true,
        refs: []
      }
    end

    it "returns deploy builds from string including before_script" do
      config = YAML.dump({
        before_script: ["pwd"],
        deploy_jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds.first.should == {
        commands: "pwd\nls",
        name: "ls",
        deploy: true,
        refs: []
      }
    end

    it "returns deploy builds from job hash" do
      config = YAML.dump({
        before_script: ["pwd"],
        deploy_jobs: [{script: "ls", name: "Rspec", refs: "master,deploy"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds.first.should == {
        commands: "pwd\nls",
        name: "Rspec",
        deploy: true,
        refs: ["master", "deploy"]
      }
    end
  end

  describe "create_commit_for_tag?" do
    it "returns true because there is a job for tags" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: [{script: "ls", name: "Rspec", runners: "mysql,ruby", tags: true}],
        deploy_jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.create_commit_for_tag?("deploy").should be_true
    end

    it "returns true because there is a deploy job for this tag" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: [{script: "ls", name: "Rspec", runner: "mysql,ruby", tags: false}],
        deploy_jobs: [{script: "ls", refs: "deploy"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.create_commit_for_tag?("deploy").should be_true
    end

    it "returns true because there is a deploy job without tag specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: [{script: "ls", name: "Rspec", runner: "mysql,ruby", tags: false}],
        deploy_jobs: ["ls"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.create_commit_for_tag?("deploy").should be_true
    end

    it "returns false because there is no deploy job for this ref nor job for tags" do
      config = YAML.dump({
        before_script: ["pwd"],
        jobs: [{script: "ls", name: "Rspec", runner: "mysql,ruby", tags: false}],
        deploy_jobs: [{script: "ls", refs: "master"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.create_commit_for_tag?("deploy").should be_false
    end
  end

  describe "#deploy_builds_for_ref" do
    it "returns deploy job for ref" do
      config = YAML.dump({
        before_script: ["pwd"],
        deploy_jobs: [{script: "ls", name: "Deploy!1", refs: "deploy"}, {script: "pwd", refs: "staging"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("deploy").size.should == 1
      config_processor.deploy_builds_for_ref("deploy").first[:name].should == 'Deploy!1'
    end

    it "returns deploy job for ref including job without ref specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        deploy_jobs: [{script: "ls", name: "Deploy!1", refs: "deploy"}, "pwd"]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("deploy").size.should == 2
    end

    it "returns empty array because there is no deploy job for this ref" do
      config = YAML.dump({
        before_script: ["pwd"],
        deploy_jobs: [{script: "ls", name: "Deploy!1", refs: "deploy"}]
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 0
    end
  end

  describe "skip_ref?" do
    it "skips ref" do
      config = YAML.dump({
          skip_refs: "master"
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.skip_ref?("master").should be_true
      config_processor.skip_ref?("deploy").should be_false
    end

    it "does not skip ref if no refs specified" do
      config = YAML.dump({})

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.skip_ref?("master").should be_false
    end
  end
  
end