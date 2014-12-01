# SlackNotificationService module
#
# Used for notifying slack about different events
#
# Ex.
#   SlackNotificationService.send_build_message(build_id)
#
module SlackNotificationService
  extend self

  def send_build_message(build_id)
    message = build_message(build_id)
    slack_notifier.ping format(message)
  end

  protected

  def slack_notifier
    @slack_notifier ||= Slack::Notifier.new(
      GitlabCi.config.slack.webhook_url,
      channel: GitlabCi.config.slack.channel,
      username: GitlabCi.config.slack.username
    )
  end

  def format(message)
    Slack::Notifier::LinkFormatter.format message
  end

  def build_message(build_id)
    build = Build.find(build_id)

    message = "GitLab-CI | #{build.project.name}\n"
    message << "Statue: #{build.status}\n"
    message << "Commit: #{build.commit.short_sha}\n"
    message << "Author: #{build.commit.git_author_name}\n"
    message << "Url: <a href='#{build_url}'>#{build.short_sha}</a>"

    message
  end

  def build_url(build)
    GitlabCi.config.gitlab_ci.host +
      "/projects/" + build.project_id + "/builds/" + build.id
  end
end
