namespace :github do
  namespace :repos do
    task :fetch, [:user_id] => :environment do |t, args|
      u = User.find args[:user_id]
      GithubRepo.all(u, true)
    end
  end
end
