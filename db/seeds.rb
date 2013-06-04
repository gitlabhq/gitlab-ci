require 'fileutils'

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
