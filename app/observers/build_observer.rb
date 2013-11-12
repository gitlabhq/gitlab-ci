class BuildObserver < BaseObserver
  def after_save(build)
    if [:failed, :success, :canceled].include? build.status
      notification.build_ended(build)
    end
  end

end
