# Use this file to easily define all of your cron jobs.
#
env :PATH, ENV['PATH']
set :output, {:error => nil, :standard => nil}

every 1.hour do
  rake "schedule_builds"
end
