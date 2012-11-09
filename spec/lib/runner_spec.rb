require 'spec_helper'

describe Runner do
  before do
  end

  it "should run a success build" do
    build = setup_build 'ls'
    Runner.new(build).run

    build.trace.should include 'six.gemspec'
    build.should be_success
  end

  it "should run a failed build" do
    build = setup_build 'cat MISSING'
    Runner.new(build).run

    build.should be_failed
  end

  def setup_build cmd
    project = FactoryGirl.create :project, scripts: cmd
    project.register_build
  end
end

