class CreateProjectService
  include Rails.application.routes.url_helpers

  def execute(current_user, params, project_route)
    @project = Project.parse(params, current_user.private_token)
    @project.build_method = CreateBuildService.new.detect_build_method(@project)
    Project.transaction do
      update(current_user, @project, project_route)
    end

    @project
  end

  def update(current_user, project, project_route)
    project.save!

    project_url = project_route.gsub(":project_id", project.id.to_s)
    hook_tag_url = "#{project_url}/tag?token=#{project.token}"

    # update only if token got changed
    enable_ci(current_user, project, project_url)
    ensure_project_hook_exist(current_user, project, project_url, hook_tag_url)
  end

  def destroy(current_user, project, project_route)
    project.destroy
    Network.new.disable_ci(current_user.url, project.gitlab_id, current_user.private_token)
    delete_project_hooks(current_user, project, project_route)
  end

  private

  def enable_ci(current_user, project, project_url)
    opts = {
        token: project.token,
        project_url: project_url
    }

    if Network.new.enable_ci(current_user.url, project.gitlab_id, opts, current_user.private_token)
      true
    else
      raise ActiveRecord::Rollback
    end
  end

  def ensure_project_hook_exist(current_user, project, project_route, hook_url)
    # check current hooks
    hooks = Network.new.list_project_hooks(current_user.url, project.gitlab_id, current_user.private_token)
    hooks ||= []

    # look for hooks with same url
    matching = hooks.select do |hook|
      hook['url'] == hook_url and hook['tag_push_events'] and not hook['push_events'] and not hook['issues_events'] and not hook['merge_request_events']
    end
    matching = matching.first

    # delete all other matching hooks
    hooks.each do |hook|
      next if matching == hook
      next unless hook['url'].start_with? project_route
      Network.new.delete_project_hook(current_user.url, project.gitlab_id, hook['id'], current_user.private_token)
    end

    # we are done, our hook is there
    return true if matching

    # push new hook
    hook_opts = {
      url: hook_url,
      push_events: false,
      issues_events: false,
      merge_request_events: false,
      tag_push_events: true
    }

    if Network.new.add_project_hook(current_user.url, project.gitlab_id, hook_opts, current_user.private_token)
      true
    else
      raise ActiveRecord::Rollback
    end
  end

  def update_project_hooks(current_user, project, project_route)
    hooks = Network.new.list_project_hooks(current_user.url, project.gitlab_id, current_user.private_token)

    if hooks
      hooks.each do |hook|
        Network.new.delete_project_hook(current_user.url, project.gitlab_id, hook['id'], current_user.private_token) if hook.url.start_with? project_route
      end
    end
  end

  def delete_project_hooks(current_user, project, project_route)
    hooks = Network.new.list_project_hooks(current_user.url, project.gitlab_id, current_user.private_token)
    return unless hooks

    hooks.each do |hook|
      next unless hook.url.start_with? project_route
      Network.new.delete_project_hook(current_user.url, project.gitlab_id, hook['id'], current_user.private_token)
    end
  end
end
