# NotificationService class
#
# Used for notifying users with emails about different events
#
# Ex.
#   NotificationService.new.build_ended(build)
#
class NotificationService
  def build_ended(build)
    build.commit.project_recipients.each do |recipient|
      case build.status.to_sym
      when :success
        mailer.build_success_email(build.id, recipient)
      when :failed
        mailer.build_fail_email(build.id, recipient)
      end
    end

    slack.send_build_message(build.id) if GitlabCi.config.slack.enabled
  end

  protected

  def mailer
    Notify.delay
  end

  def slack
    SlackNotificationService.delay
  end
end
