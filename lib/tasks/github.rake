namespace :github do
  namespace :repos do
    task :fetch, [:user_id] => :evironment do |t, args|
      u = User.find args[:user_id]
      GuthubRepo.all(u, true)
    end
  end
end
