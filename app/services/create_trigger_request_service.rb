class CreateTriggerRequestService
  def execute(project, trigger, ref, variables)
    commit = project.commits.find_by_ref(ref)
    return unless commit

    trigger_request = trigger.trigger_requests.create!(
      commit: commit,
      variables: variables
    )

    if commit.create_builds(trigger_request)
      trigger_request
    end
  end
end
