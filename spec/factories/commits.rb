# == Schema Information
#
# Table name: commits
#
#  id         :integer          not null, primary key
#  project_id :integer
#  ref        :string(255)
#  sha        :string(255)
#  before_sha :string(255)
#  push_data  :text
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commit do
    ref 'master'
    before_sha '76de212e80737a608d939f648d959671fb0a0142'
    sha '97de212e80737a608d939f648d959671fb0a0142'
    push_data do
      {
        ref: 'refs/heads/master',
        before_sha: '76de212e80737a608d939f648d959671fb0a0142',
        after_sha: '97de212e80737a608d939f648d959671fb0a0142'
      }
    end
  end
end
