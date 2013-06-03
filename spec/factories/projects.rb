# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_without_token, class: Project do
    name Faker::Name.name
    default_ref 'master'
    gitlab_url 'https://dev.gitlab.org/gitlab/six.git'
    scripts 'ls'

    factory :project do
      token 'iPWx6WM4lhHNedGfBpPJNP'
    end
  end
end
