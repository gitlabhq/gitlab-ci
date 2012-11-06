# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    token 'iPWx6WM4lhHNedGfBpPJNP'
    path '/tmp'
    scripts 'ls'
  end
end
