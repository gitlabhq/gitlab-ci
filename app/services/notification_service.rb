# NotificationService class
#
# Used for notifying users with emails about different events
#
# Ex.
#   NotificationService.new.build_ended(build)
#
class NotificationService

  def build_ended(build)
    build.project_recipients.each do |recipient|
      if build.status == :success 
        mailer.build_success_email(build.id, recipient) 
      else
        mailer.build_fail_email(build.id, recipient)
      end
    end      
  end

  protected
  
  # Do we need to delay these emails?
  def mailer
    # Notify.delay
    Notify
  end
  
end
