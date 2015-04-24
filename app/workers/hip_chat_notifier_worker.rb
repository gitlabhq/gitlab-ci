
class HipChatNotifierWorker
  include Sidekiq::Worker

  def perform(room, token, message, options={})
    client = HipChat::Client.new(token, api_version: 'v2') # v1.5.0 requires explicit version (
    client[room].send("GitLab CI", message, options)
  end
end
