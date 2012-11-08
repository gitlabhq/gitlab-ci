# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    token 'iPWx6WM4lhHNedGfBpPJNP'
    default_ref 'master'
    path Rails.root.join('tmp', 'test_repo')
    scripts 'ls'
  end
end
