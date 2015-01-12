module ProjectsHelper
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

  def runners_for_project(project)
    project.runners.map { |r| "#" + r.id.to_s }.join(", ")
  end

  def project_uses_specific_runner?(project)
    project.runners.any?
  end

  def no_shared_runners_for_project?(project)
    Runner.count.nonzero? && project.runners.blank? && Runner.shared.blank?
  end
end
