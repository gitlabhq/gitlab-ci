class HipChatMessage
  attr_reader :build

  def initialize(build)
    @build = build
  end

  def to_s
    lines = Array.new
    lines.push("<a href=\"#{RoutesHelper.project_url(build.project)}\">#{build.project.name}</a> - ")
    if build.commit.matrix?
      lines.push("<a href=\"#{RoutesHelper.project_ref_commit_url(build.project, build.commit.ref, build.commit.sha)}\">Commit ##{commit.id}</a></br>")
    else
      lines.push("<a href=\"#{RoutesHelper.project_build_url(build.project, build)}\">Build '#{build.job_name}' ##{build.id}</a></br>")
    end
    lines.push("#{build.commit.short_sha} #{build.commit.git_author_name} - #{build.commit.git_commit_message}</br>")
    lines.push("#{humanized_status} in #{build.commit.duration} second(s).")
    lines.join('')
  end

  def color
    case status
    when :success
      'green'
    when :failed, :canceled
      'red'
    when :pending, :running
      'yellow'
    else
      'random'
    end
  end

  def notify?
    [:failed, :canceled].include?(status)
  end

  private

  def status
    build.status.to_sym
  end

  def humanized_status
    case status
    when :pending
      "Pending"
    when :running
      "Running"
    when :failed
      "Failed"
    when :success
      "Successful"
    when :canceled
      "Canceled"
    else
      "Unknown"
    end
  end

end

