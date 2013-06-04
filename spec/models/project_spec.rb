# == Schema Information
#
# Table name: projects
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  timeout          :integer          default(1800), not null
#  scripts          :text             default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  token            :string(255)
#  default_ref      :string(255)
#  gitlab_url       :string(255)
#  always_build     :boolean          default(FALSE), not null
#  polling_interval :integer
#  public           :boolean          default(FALSE), not null
#  ssh_url_to_repo  :string(255)
#  gitlab_id        :integer
#

require 'spec_helper'

describe Project do
  subject { FactoryGirl.build :project }

  it { should have_many(:builds) }

  describe 'before_validation' do
    it 'should set an random token if none provided' do
      project = FactoryGirl.create :project_without_token
      project.token.should_not == ""
    end

    it 'should not set an random toke if one provided' do
      project = FactoryGirl.create :project
      project.token.should == "iPWx6WM4lhHNedGfBpPJNP"
    end
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :scripts }
  it { should validate_presence_of :timeout }
  it { should validate_presence_of :default_ref }

  context :valid_project do
    let(:project) { FactoryGirl.create :project }

    describe :register_build do
      let(:build) { project.register_build(ref: 'master', after: '31das312') }

      it { build.should be_kind_of(Build) }
      it { build.should be_pending }
      it { build.should be_valid }
      it { build.should == project.last_build }
    end

    context :project_with_build do
      before { project.register_build ref: 'master', after: '31das312' }

      it { project.status.should == 'pending' }
      it { project.last_build.should be_kind_of(Build)  }
      it { project.human_status.should == 'pending' }
      it { project.status_image.should == 'running.png' }
    end
  end
end

# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)     not null
#  path             :string(255)     not null
#  timeout          :integer(4)      default(1800), not null
#  scripts          :text            default(""), not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token            :string(255)
#  default_ref      :string(255)
#  gitlab_url       :string(255)
#  always_build     :boolean(1)      default(FALSE), not null
#  polling_interval :integer(4)
#  public           :boolean(1)      default(FALSE), not null
#

