# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    token 'iPWx6WM4lhHNedGfBpPJNP'
    default_ref 'master'
    path Rails.root.join('tmp', 'test_repo').to_s
    scripts 'ls'
    webooks 'http://localhost'
  end

  factory :project_without_token, class: Project do
    name Faker::Name.name
    default_ref 'master'
    path Rails.root.join('tmp', 'test_repo').to_s
    scripts 'ls'
    webooks 'http://localhost'
  end
end
