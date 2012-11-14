require 'spec_helper'

describe Build do
  subject { Build.new }

  it { should belong_to(:project) }
  it { should validate_presence_of :sha }
  it { should validate_presence_of :ref }
  it { should validate_presence_of :status }

  it { should respond_to :success? }
  it { should respond_to :failed? }
  it { should respond_to :running? }
  it { should respond_to :pending? }
  it { should respond_to :git_author_name }
  it { should respond_to :short_sha }
  it { should respond_to :trace_html }
end


# == Schema Information
#
# Table name: builds
#
#  id          :integer(4)      not null, primary key
#  project_id  :integer(4)
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sha         :string(255)
#

