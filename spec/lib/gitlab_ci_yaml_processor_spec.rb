require 'spec_helper'

describe GitlabCiYamlProcessor do
  
  describe "#builds_for_ref" do
    it "returns builds if no branch specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec"}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("master").size.should == 1
      config_processor.builds_for_ref("master").first.should == {
        except: nil,
        name: :rspec,
        only: nil,
        script: "pwd\nrspec",
        tags: []
      }
    end

    it "does not return builds if only has another branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", only: ["deploy"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("master").size.should == 0
    end

    it "does not return builds if only has regexp with another branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", only: ["/^deploy$/"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("master").size.should == 0
    end

    it "returns builds if only has specified this branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", only: ["master"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("master").size.should == 1
    end

    it "does not build tags" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", exclude: ["tags"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("0-1", true).size.should == 1
    end
  end

  describe "#deploy_builds_for_ref" do
    it "returns builds if no branch specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy"}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 1
      config_processor.deploy_builds_for_ref("master").first.should == {
        except: nil,
        name: :rspec,
        only: nil,
        script: "pwd\nrspec",
        tags: []
      }
    end

    it "does not return builds if only has another branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy", only: ["deploy"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 0
    end

    it "does not return builds if only has regexp with another branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy", only: ["/^deploy$/"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 0
    end

    it "returns builds if only has specified this branch" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy", only: ["master"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 1
    end
  end

  describe "Error handling" do
    it "indicated that object is invalid" do
      config_processor = GitlabCiYamlProcessor.new("invalid_yaml\n!ccdvlf%612334@@@@")

      config_processor.valid?.should be_false
    end
  end
end