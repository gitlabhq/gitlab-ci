require './app.rb'

require 'resque/server'

run Rack::URLMap.new(
  "/"       => GitlabCi.new,
  "/resque" => Resque::Server.new
)
