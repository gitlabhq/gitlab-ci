# == Schema Information
#
# Table name: services
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)
#  project_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean          default(FALSE), not null
#  properties :text
#

class SlackService < Service
  prop_accessor :webhook
  prop_accessor :notify_only_broken_builds
  validates :webhook, presence: true, if: :activated?

  default_value_for :notify_only_broken_builds, true

  def title
    'Slack'
  end

  def description
    'A team communication tool for the 21st century'
  end

  def to_param
    'slack'
  end

  def help
    'Visit https://www.slack.com/services/new/incoming-webhook. Then copy link and save project!' unless webhook.present?
  end

  def fields
    [
        {type: 'text', name: 'webhook', label: 'Webhook URL', placeholder: ''},
        {type: 'checkbox', name: 'notify_only_broken_builds', label: 'Notify only broken builds'}
    ]
  end

  def notify_only_broken_builds?
    notify_only_broken_builds == '1'
  end

  def can_test?
    # slack notification is useful only for builds either successful or failed
    builds = project.builds
    return builds.failed.any? if notify_only_broken_builds?
    builds.failed.any? || builds.success.any?
  end

  def execute(build)
    commit = build.commit
    return unless commit
    return unless commit.builds_without_retry.include?(build)

    case commit.status.to_sym
      when :failed
      when :success
        return if notify_only_broken_builds?
      else
        return
    end

    message = SlackMessage.new(commit)
    options = default_options.merge(
        color: message.color,
        fallback: message.fallback,
        attachments: message.attachments
    )
    SlackNotifierWorker.perform_async(webhook, message.pretext, options)
  end

  private

  def default_options
    {
        username: 'GitLab CI'
    }
  end
end
