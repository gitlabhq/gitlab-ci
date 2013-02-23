class Notifier
  include Sidekiq::Worker

  attr_accessor :project, :build, :state

  sidekiq_options queue: :notifier

  def perform(build_id, state)
    ActiveRecord::Base.connection_pool.with_connection do
      @build   = Build.find(build_id)
      @project = @build.project
      @state   = state
      notify_github!
    end
  end

  def notify_github!
    return false unless to_github?

    tm = build.finished_at.to_i - build.started_at.to_i
    g_state = case state
              when "success"
                "success"
              when "failed"
                "failure"
              when "canceled"
                "failure"
              end
    g_target_url = "http://#{Settings.hostname}/projects/#{project.id}/builds/#{build.sha}?bid=#{build.id}"
    g_desc = case g_state
             when "success"
               "Build ##{build.id} successed in #{tm}s"
             when "failure"
               "Build ##{build.id} failed in #{tm}s"
             end
    post_status_to_github(g_state, g_target_url, g_desc)
  end

  def post_status_to_github(st, url, desc)
    post_to = "/repos/#{project.name}/statuses/#{build.sha}"
    puts "Notifier: #{post_to} #{st}"
    if project.session
      project.session.post(post_to,
                           state: st,
                           target_url: url,
                           description: desc)
    end
  end

  def to_github?
    states = %w{ success canceled failed }
    project.github? && states.include?(state)
  end
end
