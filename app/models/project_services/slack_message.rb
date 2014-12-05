require 'slack-notifier'

class SlackMessage
  # default_url_options[:host]     = GitlabCi.config.gitlab_ci.host
  # default_url_options[:protocol] = GitlabCi.config.gitlab_ci.protocol
  # default_url_options[:port]     = GitlabCi.config.gitlab_ci.port if GitlabCi.config.gitlab_ci_on_non_standard_port?
  # default_url_options[:script_name] = GitlabCi.config.gitlab_ci.relative_url_root

  def initialize(commit)
    @commit = commit
  end

  def pretext
    ''
  end

  def color
    attachment_color
  end

  def fallback
    format(attachment_message)
  end

  def attachments
    fields = []

    if commit.matrix?
      commit.builds_without_retry.each do |build|
        next unless build.failed?
        fields << {
            title: build.job_name,
            value: "Build <#{build_log_link(build)}|\##{build.id}> failed in #{build.duration.to_i} second(s)."
        }
      end
    end

    [{
         text: attachment_message,
         color: attachment_color,
         fields: fields
     }]
  end

  private

  attr_reader :commit

  def attachment_message
    out = "<#{project_url}|#{project_name}>: "
    if commit.matrix?
      out << "Commit <#{commit_url}|\##{commit.id}> "
    else
      build = commit.builds_without_retry.first
      out << "Build <#{build_log_link(build)}|\##{build.id}> "
    end
    out << "(<#{commit_sha_link}|#{commit.short_sha}>) "
    out << "of <#{commit_ref_link}|#{commit.ref}> "
    out << "by #{commit.git_author_name} " if commit.git_author_name
    out << "#{commit_status} in "
    out << "#{commit.duration} second(s)"
  end

  def format(string)
    Slack::Notifier::LinkFormatter.format(string)
  end

  def project
    commit.project
  end

  def project_name
    project.name
  end

  def commit_sha_link
    if commit.project.gitlab?
      "#{project.gitlab_url}/commit/#{commit.sha}"
    else
      commit.ref
    end
  end

  def commit_ref_link
    if commit.project.gitlab?
      "#{project.gitlab_url}/commits/#{commit.ref}"
    else
      commit.ref
    end
  end

  def attachment_color
    if commit.success?
      'good'
    else
      'danger'
    end
  end

  def commit_status
    if commit.success?
      'succeeded'
    else
      'failed'
    end
  end

  def project_url
    Rails.application.routes.url_helpers.project_url(
        project,
        url_helper_options
    )
  end

  def commit_url
    Rails.application.routes.url_helpers.project_commit_url(
        project, commit,
        url_helper_options
    )
  end

  def build_log_link(build)
    Rails.application.routes.url_helpers.project_build_url(
        project, build,
        url_helper_options
    )
  end

  def url_helper_options
    {
        host: Settings.gitlab_ci['host'],
        protocol: Settings.gitlab_ci['https'] ? "https" : "http",
        port: Settings.gitlab_ci['port']
    }
  end
end
