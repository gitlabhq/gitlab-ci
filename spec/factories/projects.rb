# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_without_token, class: Project do
    name 'GitLab / gitlab-shell'
    default_ref 'master'
    gitlab_url 'http://demo.gitlabhq.com/gitlab/gitlab-shell'
    ssh_url_to_repo 'git@demo.gitlab.com:gitlab/gitlab-shell.git'
    gitlab_id 8
    scripts 'ls'

    factory :project do
      token 'iPWx6WM4lhHNedGfBpPJNP'
    end
  end
end
