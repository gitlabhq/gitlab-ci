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
