FactoryGirl.define do
  factory :web_hook do
    sequence(:url) { FFaker::Internet.uri('http') }
    project
  end
end
