require 'sinatra/activerecord/rake'
require 'resque/tasks'
require './app'

desc 'Create new user:  rake add_user test@test.com pAs$word'
task :add_user do
  pass  = ARGV[2]
  email = ARGV[1]

  user = User.create(email: email, password: User.encrypt(pass))
  if user.valid?
    puts "SUCCESS"
  else
    puts "ERROR"
  end
  task email.to_sym do ; end
  task pass.to_sym do ; end
end

desc 'Interactive console'
task :console do
  sh 'pry -r ./app.rb'
end
task :c => :console
