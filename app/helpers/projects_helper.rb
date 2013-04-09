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

  def success_ratio(success_builds, failed_builds)
    failed_builds = failed_builds.count
    success_builds = success_builds.count

    return 100 if failed_builds.zero?

    ratio = (success_builds.to_f / (success_builds + failed_builds)) * 100
    ratio.to_i
  end

  def markdown_badge_code(project, ref)
    url = status_project_url(project, ref: ref, format: 'png')
    "[![build status](#{url})](#{project_url(project, ref: ref)})"
  end

  def html_badge_code(project, ref)
    url = status_project_url(project, ref: ref, format: 'png')
    "<a href='#{project_url(project, ref: ref)}'><img src='#{url}' /></a>"
  end
end
