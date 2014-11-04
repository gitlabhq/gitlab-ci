module CommitsHelper
  def commit_status_alert_class(commit)
    if commit.success?
      'alert-success'
    elsif commit.failed? || commit.canceled?
      'alert-danger'
    else
      'alert-warning'
    end
  end
end
