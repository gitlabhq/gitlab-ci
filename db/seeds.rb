# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
User.create(
  email: "admin@local.host",
  password: "5iveL!fe",
  password_confirmation: "5iveL!fe"
)


if Rails.env == 'development'
  `cd #{Rails.root.join('tmp')} && git clone https://github.com/randx/six.git test_repo`

  FactoryGirl.create :project,
    name: "Six",
    scripts: 'bundle exec rspec spec'
end
