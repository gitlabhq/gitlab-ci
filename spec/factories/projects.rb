# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    token 'iPWx6WM4lhHNedGfBpPJNP'
    default_ref 'master'
    path Rails.root.join('tmp', 'test_repo').to_s
    scripts 'ls'

    factory :github_project, class: GithubProject do
      user
      github_repo_id 1
      clone_url { |n| "git@github.com:evrone/repo#{n}.git" }
      public_key { |n| "public_key_#{n}"}
      private_key { |n| "private_key_#{n}"}
    end
  end

  factory :project_without_token, class: Project do
    name Faker::Name.name
    default_ref 'master'
    path Rails.root.join('tmp', 'test_repo').to_s
    scripts 'ls'
  end
end
