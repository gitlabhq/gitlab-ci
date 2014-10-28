desc "GitLab CI | Setup gitlab db"
task :setup do
  Rake::Task["db:setup"].invoke
  Rake::Task["add_limits_mysql"].invoke
end
