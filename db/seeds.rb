# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
User.create(
  email: "admin@local.host",
  password: "5iveL!fe",
  password_confirmation: "5iveL!fe"
)


if Rails.env == 'development'
  `rm -rf #{Rails.root.join('tmp', 'test_repo')}`
  `cd #{Rails.root.join('tmp')} && git clone https://github.com/randx/six.git test_repo`

  project = FactoryGirl.create :project,
    name: "Six",
    scripts: 'bundle exec rspec spec'

  project.repo.commits('master', 20).each_with_index do |commit, index|
    build = project.register_build(
      ref: 'master',
      before: commit.parents.first.id,
      after: commit.id
    )

    Runner.perform_in(index.minutes, build.id)
  end
end
