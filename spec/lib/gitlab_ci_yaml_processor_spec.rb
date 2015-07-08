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
        tags: [],
        options: {},
        allow_failure: false
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
        rspec: {script: "rspec", except: ["tags"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("0-1", true).size.should == 0
    end
  end

  describe "#deploy_builds_for_ref" do
    it "returns builds if no branch specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy", allow_failure: true}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("master").size.should == 1
      config_processor.deploy_builds_for_ref("master").first.should == {
        except: nil,
        name: :rspec,
        only: nil,
        script: "pwd\nrspec",
        tags: [],
        options: {},
        allow_failure: true
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

    it "returns builds if only has a list of branches including specified" do
      config = YAML.dump({
        before_script: ["pwd"],
        rspec: {script: "rspec", type: "deploy", only: ["master", "deploy"]}
      })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.deploy_builds_for_ref("deploy").size.should == 1
    end
  end

  describe "Image and service handling" do
    it "returns image and service when defined" do
      config = YAML.dump({
                           image: "ruby:2.1",
                           services: ["mysql"],
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
        tags: [],
        options: {
          image: "ruby:2.1",
          services: ["mysql"]
        },
        allow_failure: false
      }
    end

    it "returns image and service when overridden for job" do
      config = YAML.dump({
                           image: "ruby:2.1",
                           services: ["mysql"],
                           before_script: ["pwd"],
                           rspec: {image: "ruby:2.5", services: ["postgresql"], script: "rspec"}
                         })

      config_processor = GitlabCiYamlProcessor.new(config)

      config_processor.builds_for_ref("master").size.should == 1
      config_processor.builds_for_ref("master").first.should == {
        except: nil,
        name: :rspec,
        only: nil,
        script: "pwd\nrspec",
        tags: [],
        options: {
          image: "ruby:2.5",
          services: ["postgresql"]
        },
        allow_failure: false
      }
    end
  end

  describe "Error handling" do
    it "indicates that object is invalid" do
      expect{GitlabCiYamlProcessor.new("invalid_yaml\n!ccdvlf%612334@@@@")}.to raise_error(GitlabCiYamlProcessor::ValidationError)
    end

    it "returns errors if tags parameter is invalid" do
      config = YAML.dump({rspec: {tags: "mysql"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "rspec job: tags parameter should be an array")
    end

    it "returns errors if before_script parameter is invalid" do
      config = YAML.dump({before_script: "bundle update", rspec: {script: "test"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "before_script should be an array")
    end

    it "returns errors if image parameter is invalid" do
      config = YAML.dump({image: ["test"], rspec: {script: "test"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "image should be a string")
    end

    it "returns errors if job image parameter is invalid" do
      config = YAML.dump({rspec: {image: ["test"]}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "rspec job: image should be a string")
    end

    it "returns errors if services parameter is not an array" do
      config = YAML.dump({services: "test", rspec: {script: "test"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "services should be an array of strings")
    end

    it "returns errors if services parameter is not an array of strings" do
      config = YAML.dump({services: [10, "test"], rspec: {script: "test"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "services should be an array of strings")
    end

    it "returns errors if job services parameter is not an array" do
      config = YAML.dump({rspec: {services: "test"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "rspec job: services should be an array of strings")
    end

    it "returns errors if job services parameter is not an array of strings" do
      config = YAML.dump({rspec: {services: [10, "test"]}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "rspec job: services should be an array of strings")
    end

    it "returns errors if there are unknown parameters" do
      config = YAML.dump({extra: "bundle update"})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "Unknown parameter: extra")
    end

    it "returns errors if there is no any jobs defined" do
      config = YAML.dump({before_script: ["bundle update"]})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "Please define at least one job")
    end

    it "returns errors if job allow_failure parameter is not an boolean" do
      config = YAML.dump({rspec: {script: "test", allow_failure: "string"}})
      expect do
        GitlabCiYamlProcessor.new(config)
      end.to raise_error(GitlabCiYamlProcessor::ValidationError, "rspec job: allow_failure parameter should be an boolean")
    end
  end
end