module BuildsHelper
  def build_ref_link build
    gitlab_ref_link build.project, build.ref
  end

  def build_compare_link build
    gitlab_compare_link build.project, build.commit.short_before_sha, build.short_sha
  end

  def build_commit_link build
    gitlab_commit_link build.project, build.short_sha
  end

  def build_url(build)
    project_build_path(build.project, build)
  end

  def build_status_alert_class(build)
    if build.success?
      'alert-success'
    elsif build.failed?
      'alert-danger'
    elsif build.canceled?
      'alert-disabled'
    else
      'alert-warning'
    end
  end

  def build_icon_css_class(build)
    if build.success?
      'icon-circle cgreen'
    elsif build.failed?
      'icon-circle cred'
    else
      'icon-circle light'
    end
  end
end
