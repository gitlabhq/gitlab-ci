# SlackNotificationService class
#
# Used for notifying users with on slack about different events
#
# Ex.
#   SlackNotificationService.new.build_ended(build)
#
require 'slack_notifier'

class SlackNotificationService
  def build_ended(build)
    case build.status.to_sym
    when :success
      Slack::Notifier.build_success_slack_post(build)
    when :failed
      Slack::Notifier.build_fail_slack_post(build)
    end
  end

end
