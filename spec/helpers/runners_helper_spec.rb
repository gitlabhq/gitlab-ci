require 'spec_helper'

describe RunnersHelper do
  it "returns - not contacted yet" do
    runner = FactoryGirl.build :runner
    expect(runner_status_icon(runner)).to include("not connected yet")
  end

  it "returns offline text" do
    runner = FactoryGirl.build(:runner, contacted_at: 1.day.ago, active: true)
    expect(runner_status_icon(runner)).to include("Runner is offline")
  end

  it "returns online text" do
    runner = FactoryGirl.build(:runner, contacted_at: 1.hour.ago, active: true)
    expect(runner_status_icon(runner)).to include("Runner is online")
  end
end
