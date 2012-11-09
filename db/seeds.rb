# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
User.create(
  email: "admin@local.host",
  password: "5iveL!fe",
  password_confirmation: "5iveL!fe"
)

if Rails.env == 'development'
  5.times do
    Project.create(
      name: "Test",
      path: "/tmp",
      token: "u4asd4u320a",
      scripts: "ls",
      default_ref: 'master'
    )
  end
end
