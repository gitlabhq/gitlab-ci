require 'slack-notifier'

class SlackMessage
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
          value: "Build <#{RoutesHelper.project_build_url(project, build)}|\##{build.id}> failed in #{build.duration.to_i} second(s)."
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
    out = "<#{RoutesHelper.project_url(project)}|#{project_name}>: "
    if commit.matrix?
      out << "Commit <#{RoutesHelper.project_commit_url(project, commit)}|\##{commit.id}> "
    else
      build = commit.builds_without_retry.first
      out << "Build <#{RoutesHelper.project_build_url(project, build)}|\##{build.id}> "
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
end
