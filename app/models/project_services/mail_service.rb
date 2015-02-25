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

class MailService < Service
  delegate :email_recipients, :email_recipients=,
           :email_add_committer, :email_add_committer=,
           :email_only_broken_builds, :email_only_broken_builds=, to: :project, prefix: false

  before_save :update_project

  default_value_for :active, true

  def title
    'Mail'
  end

  def description
    'Email notification'
  end

  def to_param
    'mail'
  end

  def fields
    [
      { type: 'text', name: 'email_recipients', label: 'Recipients', help: 'Whitespace-separated list of recipient addresses' },
      { type: 'checkbox', name: 'email_add_committer', label: 'Add committer to recipients list' },
      { type: 'checkbox', name: 'email_only_broken_builds', label: 'Notify only broken builds' }
    ]
  end

  def can_test?
    # e-mail notification is useful only for builds either successful or failed
    project.builds.order(id: :desc).any? do |build|
      return false unless build.commit.project_recipients.any?

      case build.status.to_sym
      when :failed
        true
      when :success
        !email_only_broken_builds
      else
        false
      end
    end
  end

  def execute(build)
    # it doesn't make sense to send emails for retried builds
    commit = build.commit
    return unless commit
    return unless commit.builds_without_retry.include?(build)

    commit.project_recipients.each do |recipient|
      case build.status.to_sym
      when :success
        return if email_only_broken_builds
        mailer.build_success_email(build.id, recipient)
      when :failed
        mailer.build_fail_email(build.id, recipient)
      end
    end
  end

  private

  def update_project
    project.save!
  end

  def mailer
    Notify.delay
  end
end
