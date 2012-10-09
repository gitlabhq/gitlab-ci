class Build < ActiveRecord::Base
  belongs_to :project

  def failed?
    status == 'fail'
  end

  def success?
    status == 'success'
  end

  def running?
    status == 'running'
  end

  def success!
    update_status 'success'
  end

  def fail!
    update_status 'fail'
  end

  def running!
    update_status 'running'
  end

  def update_status status
    update_attributes(status: status)
  end

  def write_trace(trace)
    self.reload
    update_attributes(trace: trace)
  end
end
