# NotificationService class
#
# Used for notifying users with emails about different events
#
# Ex.
#   NotificationService.new.build_ended(build)
#
class NotificationService

  def build_ended(build)
    if !GitlabCi.config.gitlab_ci.only_fail_notifications
      build.status == :success ? mailer.build_success_email(build.id) : mailer.build_fail_email(build.id)
    elsif build.status == :failed  
      mailer.build_fail_email(build.id)
    end
  end

  protected
  
  # Do we need to delay these emails?
  def mailer
    # Notify.delay
    Notify
  end
end
