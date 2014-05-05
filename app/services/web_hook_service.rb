class WebHookService
  def build_end(build)
    execute_hooks(build.project, build_data(build))
  end

  def execute_hooks(project, data)
    project.web_hooks.each do |wh|
      async_execute_hook wh, data
    end
  end

  def async_execute_hook(hook, data)
    Sidekiq::Client.enqueue(WebHookWorker, hook.id, data)
  end

  def build_data(build)
    project = build.project
    data = {}
    data.merge!({
      id: build.id,
      project_id: project.id,
      project_name: project.name,
      gitlab_url: project.gitlab_url,
      ref: build.ref,
      status: build.status,
      started_at: build.started_at,
      finished_at: build.finished_at,
      sha: build.sha,
      before_sha: build.before_sha,
      push_data: build.push_data

    })
  end
end
