module BuildsHelper
  def build_ref_link build
    if build.commit.gitlab?
      gitlab_ref_link build.project, build.ref
    else
      build.ref
    end
  end

  def build_compare_link build
    if build.commit.gitlab?
      gitlab_compare_link build.project, build.commit.short_before_sha, build.short_sha
    end
  end

  def build_commit_link build
    if build.commit.gitlab?
      gitlab_commit_link build.project, build.short_sha
    else
      build.short_sha
    end
  end

  def build_url(build)
    project_build_url(build.project, build)
  end

  def build_status_alert_class(build)
    if build.success?
      'alert-success'
    elsif build.failed? || build.canceled?
      'alert-danger'
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

  def truncate_project_token(string)
    string.gsub(@project.token, 'xxxxxx')
  end
end
