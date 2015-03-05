module CommitsHelper
  def commit_status_alert_class(commit)
    return unless commit

    case commit.status
    when 'success'
      'alert-success'
    when 'failed', 'canceled'
      'alert-danger'
    else
      'alert-warning'
    end
  end

  def commit_link(commit)
    link_to(commit.short_sha, project_show_commit_path(commit.project, sha: commit.sha, ref: commit.ref))
  end
end
