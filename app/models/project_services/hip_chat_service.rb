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

class HipChatService < Service
  prop_accessor :hipchat_token, :hipchat_room, :hipchat_server
  boolean_accessor :notify_only_broken_builds
  validates :hipchat_token, presence: true, if: :activated?
  validates :hipchat_room, presence: true, if: :activated?
  default_value_for :notify_only_broken_builds, true

  def title
    "HipChat"
  end

  def description
    "Private group chat, video chat, instant messaging for teams"
  end

  def help
  end

  def to_param
    'hip_chat'
  end

  def fields
    [
      { type: 'text', name: 'hipchat_token',  label: 'Token', placeholder: '' },
      { type: 'text', name: 'hipchat_room',   label: 'Room', placeholder: '' },
      { type: 'text', name: 'hipchat_server', label: 'Server', placeholder: 'https://hipchat.example.com', help: 'Leave blank for default' },
      { type: 'checkbox', name: 'notify_only_broken_builds', label: 'Notify only broken builds' }
    ]
  end

  def execute build
    commit = build.commit
    return unless commit
    return unless commit.builds_without_retry.include? build

    msg = HipChatMessage.new(build)
    HipChatNotifierWorker.perform_async(hipchat_room, hipchat_token, msg.to_s, {
      message_format: 'html',
      color: msg.color,
      notify: notify_only_broken_builds? && msg.notify?
    })
  end

  private

  def default_options
    {
      hipchat_server: 'https://api.hipchat.com'
    }
  end

end
