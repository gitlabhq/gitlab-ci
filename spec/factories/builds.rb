# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime
#  updated_at  :datetime
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  runner_id   :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    ref 'master'
    before_sha '76de212e80737a608d939f648d959671fb0a0142'
    sha '97de212e80737a608d939f648d959671fb0a0142'
    started_at 'Di 29. Okt 09:51:28 CET 2013'
    finished_at 'Di 29. Okt 09:53:28 CET 2013'
  end
end
