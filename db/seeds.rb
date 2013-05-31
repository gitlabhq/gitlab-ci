require 'fileutils'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
User.create(
  email: "admin@local.host",
  password: "5iveL!fe",
  password_confirmation: "5iveL!fe"
)


if %w(development test).include?(Rails.env)
  print "Unpacking seed repository..."

  SEED_REPO = 'six.tar.gz'
  REPO_PATH = Rails.root.join('tmp', 'repositories')

  # Make whatever directories we need to make
  FileUtils.mkdir_p(REPO_PATH)

  # Copy the archive to the repo path
  FileUtils.cp(Rails.root.join('spec', SEED_REPO), REPO_PATH)

  # chdir to the repo path
  FileUtils.cd(REPO_PATH) do
    # Extract the archive
    `tar -xf #{SEED_REPO}`

    # Remove the copy
    FileUtils.rm(SEED_REPO)
  end

  puts ' done.'
end

if Rails.env == 'development'
  puts 'Creating projets with builds '

  project = FactoryGirl.create :project,
    name: "Six",
    gitlab_url: 'https://dev.gitlab.org/gitlab/six',
    scripts: 'bundle exec rspec spec'


  push_data = {
    "before" => "1c8a9df454ef68c22c2a33cca8232bb50849e5c5",
    "after" => "2e008a711430a16092cd6a20c225807cb3f51db7",
    "ref" => "refs/heads/master",
    "user_id" => 1,
    "user_name" => "Dmitriy Zaporozhets",
    "repository" => {
      "name" => "six",
      "url" => "git@dev.gitlab.org:gitlab/six.git",
      "description" => "",
      "homepage" => "https://dev.gitlab.org/gitlab/six"
    },
    "commits" => [
      {
        "id" => "2e008a711430a16092cd6a20c225807cb3f51db7",
        "message" => "Added codeclimate badge",
        "timestamp" => "2012-10-10T09:11:19+00:00",
        "url" => "https://dev.gitlab.org/gitlab/six/commit/2e008a711430a16092cd6a20c225807cb3f51db7",
        "author" => {
          "name" => "Dmitriy Zaporozhets",
          "email" => "dmitriy.zaporozhets@gmail.com"
        }
      }
    ],
    "total_commits_count" => 1
  }

  10.times do
    build = project.register_build(HashWithIndifferentAccess.new(push_data))
  end
end
