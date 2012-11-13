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

  it "white bold boys have more fun" do
    Ansi2html::convert("\e[37m\e[1mHello\e[0m\e[0m").should == '<span class="white"><span class="bold">Hello</span></span>'
  end
end
