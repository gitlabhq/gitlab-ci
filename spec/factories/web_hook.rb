FactoryGirl.define do
  factory :web_hook do
    sequence(:url) { Faker::Internet.uri('http') }
  end
end
