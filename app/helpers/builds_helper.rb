module BuildsHelper
  def build_duration build
    if build.started?
      from = build.started_at
      to = build.finished_at || Time.zone.now
      distance_of_time_in_words(from, to)
    end
  end

  def build_ref_link build
    if build.gitlab?
      gitlab_ref_link build.project, build.ref
    else
      build.ref
    end
  end

  def build_compare_link build
    if build.gitlab?
      gitlab_compare_link build.project, build.short_before_sha, build.short_sha
    end
  end

  def build_commit_link build
    if build.gitlab?
      gitlab_commit_link build.project, build.short_sha
    else
      build.short_sha
    end
  end

  def build_link build
    link_to(build.short_sha, project_build_path(build.project, build))
  end

  def action_links_for build
    content = ''
    if build.active?
      content = link_to "Cancel", cancel_project_build_path(build.project, build.id), class: 'btn btn-small btn-danger'
    else
      content = link_to "Rebuild", retry_project_build_path(build.project, build.sha), class: 'btn btn-small', method: :post
    end
    if build.deployed? || build.deployable?
      content += link_to build.deployed? ? "Redeploy" : "Deploy", deploy_project_build_path(build.project, build.sha), class: 'btn btn-small', method: :post
    end
    content
  end
	
  def build_status_alert_class build
    if build.success?
      'alert-success'
    elsif build.deployed?
      'alert-info'
    elsif build.failed? || build.canceled?
      'alert-error'
    else
      ''
    end
  end

  def test_status_icon test
    case test.status
      when 'failed' then 'icon-exclamation-sign'
      when 'success' then 'icon-check'
      when 'pending' then 'icon-cogs'
      when 'skipped' then 'icon-check-empty'
      else
        ''
    end
  end

  def test_status_alert_class test
    case test.status
      when 'failed' then 'alert-error'
      when 'success' then 'alert-success'
      when 'pending' || 'skipped' then 'alert'
      else ''
    end
  end
end
