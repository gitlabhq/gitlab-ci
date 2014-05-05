class WebHookWorker
  include Sidekiq::Worker

  def perform(hook_id, data)
    WebHook.find(hook_id).execute data
  end
end
