module CommitsHelper
  def commit_status_alert_class(commit)
    case commit.status
    when 'success'
      'alert-success'
    when 'failed', 'canceled'
      'alert-danger'
    else
      'alert-warning'
    end
  end
end
