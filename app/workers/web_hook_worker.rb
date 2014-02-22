class WebHookWorker
  include Sidekiq::Worker

  sidekiq_options queue: :web_hook

  def perform(hook_id, data)
    WebHook.find(hook_id).execute data
  end
end
