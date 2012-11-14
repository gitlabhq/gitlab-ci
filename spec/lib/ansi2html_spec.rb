require 'spec_helper'

describe Ansi2html do
  it "prints non-ansi as-is" do
    Ansi2html::convert("Hello").should == 'Hello'
  end

  it "prints simply red" do
    Ansi2html::convert("\e[31mHello\e[0m").should == '<span class="red">Hello</span>'
  end

  it "prints simply yellow" do
    Ansi2html::convert("\e[33mHello\e[0m").should == '<span class="yellow">Hello</span>'
  end

  it "prints simply blue" do
    Ansi2html::convert("\e[34mHello\e[0m").should == '<span class="blue">Hello</span>'
  end

  it "prints simply grey" do
    Ansi2html::convert("\e[90mHello\e[0m").should == '<span class="grey">Hello</span>'
  end

  it "ignore nested bold" do
    Ansi2html::convert("\e[37m\e[1mHello\e[0m\e[0m").should == '<span class="white">Hello</span>'
  end

  it "should print cucumber style" do
    Ansi2html::convert("\e[1;32mScenario:\e[0m").should == '<span class="green">Scenario:</span>'
  end

  it 'should always close tags' do
    Ansi2html::convert("\e[1;32mScenario: User sign up").should == '<span class="green">Scenario: User sign up</span>'
  end
end
