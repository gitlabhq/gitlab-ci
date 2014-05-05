desc "GitLab | Setup gitlab db"
task :setup do
  setup_db
end

def setup_db
  Rake::Task["db:setup"].invoke
  Rake::Task["add_limits_mysql"].invoke
end
