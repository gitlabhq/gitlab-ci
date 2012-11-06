require 'spec_helper'

describe Project do
  subject { Project.new }

  it { should have_many(:builds) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :path }
  it { should validate_presence_of :scripts }
  it { should validate_presence_of :timeout }
  it { should validate_presence_of :token }
end
