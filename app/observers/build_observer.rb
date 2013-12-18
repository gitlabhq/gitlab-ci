class BuildObserver < BaseObserver
  def after_save(build)
    project = build.project
    if project.email_notification?
      if (project.email_all_broken_builds? && project.broken?) || project.last_build_changed_status?
        notification.build_ended(build)
      end
    end
  end

end
