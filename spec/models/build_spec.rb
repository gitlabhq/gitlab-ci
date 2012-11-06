require 'spec_helper'

describe Build do
  subject { Build.new }

  it { should belong_to(:project) }
end

