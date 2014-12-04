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
  validates :webhook, presence: true, if: :activated?

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
        {type: 'text', name: 'webhook', placeholder: ''}
    ]
  end

  def execute(build)
    message = SlackMessage.new(build)

    credentials = webhook.match(/([\w-]*).slack.com.*services\/(.*)/)

    if credentials.present?
      subdomain = credentials[1]
      token = credentials[2].split("token=").last
      notifier = Slack::Notifier.new(subdomain, token)
      notifier.ping(message.pretext, color: message.color, fallback: message.pretext, attachments: message.attachments)
    end
  end
end
