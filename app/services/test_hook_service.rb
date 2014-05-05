class TestHookService
  def execute(hook, current_user)
    WebHookService.new.build_end(hook.project.last_build)
  end
end
