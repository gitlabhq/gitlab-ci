# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  timeout                  :integer          default(1800), not null
#  scripts                  :text             not null
#  created_at               :datetime
#  updated_at               :datetime
#  token                    :string(255)
#  default_ref              :string(255)
#  gitlab_url               :string(255)
#  always_build             :boolean          default(FALSE), not null
#  polling_interval         :integer
#  public                   :boolean          default(FALSE), not null
#  ssh_url_to_repo          :string(255)
#  gitlab_id                :integer
#  allow_git_fetch          :boolean          default(TRUE), not null
#  email_recipients         :string(255)      default(""), not null
#  email_add_committer      :boolean          default(TRUE), not null
#  email_only_broken_builds :boolean          default(TRUE), not null
#

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
