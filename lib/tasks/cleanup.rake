namespace :cleanup do
  desc "GitLab CI | Clean running builds"
  task builds: :environment do
    Build.running.update_all(status: 'canceled')
  end
end
