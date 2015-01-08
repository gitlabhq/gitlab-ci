class TestHookService
  def execute(hook, current_user)
    WebHookService.new.build_end(hook.project.commits.last.last_build)
  end
end
