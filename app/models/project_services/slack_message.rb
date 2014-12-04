require 'slack-notifier'

class SlackMessage
  # default_url_options[:host]     = GitlabCi.config.gitlab_ci.host
  # default_url_options[:protocol] = GitlabCi.config.gitlab_ci.protocol
  # default_url_options[:port]     = GitlabCi.config.gitlab_ci.port if GitlabCi.config.gitlab_ci_on_non_standard_port?
  # default_url_options[:script_name] = GitlabCi.config.gitlab_ci.relative_url_root

  def initialize(build)
    @build = build
  end

  def pretext
    format(message)
  end

  def color
    attachment_color
  end

  def attachments
    message_attachments
  end

  private

  attr_reader :build

  def message
    if build.complete?
      "<#{project_url}|#{project_name}>: Build <#{build_url}|\##{build.id}> (<#{build_ref_link}|#{build.short_sha}>) of #{build.ref} by #{build.commit.git_author_name} #{build.status} in #{build.duration} second(s)"
    end
  end

  def message_attachments
    []
  end

  def format(string)
    Slack::Notifier::LinkFormatter.format(string)
  end

  def project_name
    build.project.name
  end

  def build_ref_link
    if build.project.gitlab?
      "#{build.project.gitlab_url}/commits/#{build.ref}"
    else
      build.ref
    end
  end

  def attachment_color
    if build.success?
      'good'
    else
      'danger'
    end
  end

  def project_url
    Rails.application.routes.url_helpers.project_url(
        build.project,
        host: Settings.gitlab_ci['host'], protocol: Settings.gitlab_ci['https'] ? "https" : "http", port: Settings.gitlab_ci['port']
    )
  end

  def build_url
    Rails.application.routes.url_helpers.project_build_url(
        build.project, build,
        host: Settings.gitlab_ci['host'], protocol: Settings.gitlab_ci['https'] ? "https" : "http", port: Settings.gitlab_ci['port']
    )
  end
end
