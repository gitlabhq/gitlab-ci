module ProjectsHelper
  def project_statuc_class(project)
    if project.last_build.try :success?
      'alert-success'
    elsif project.last_build.try :failed?
      'alert-error'
    else
      ''
    end
  end

  def build_status_alert_class build
    if build.success?
      'alert-success'
    elsif build.failed? || build.canceled?
      'alert-error'
    else
      ''
    end
  end

  def ref_tab_class ref = nil
    'active' if ref == @ref
  end

  def success_ratio(project)
    failed_builds = project.builds.failed.count
    success_buids = project.builds.success.count

    if failed_builds.zero?
      return 100
    end

    (success_buids.to_f / (success_buids + failed_builds)) * 100
  end
end
