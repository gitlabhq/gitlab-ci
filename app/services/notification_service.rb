# NotificationService class
#
# Used for notifying users with emails about different events
#
# Ex.
#   NotificationService.new.build_ended(build)
#
class NotificationService
  def build_ended(build)
    return unless build.build_group
    build.project_recipients.each do |recipient|
      case build.build_group.status.to_sym
      when :success
        mailer.build_success_email(build.id, recipient)
      when :failed
        mailer.build_fail_email(build.id, recipient)
      end
    end
  end

  protected

  def mailer
    Notify.delay
  end
end
