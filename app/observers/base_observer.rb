class BaseObserver < ActiveRecord::Observer
  def notification
    NotificationService.new
  end

end
