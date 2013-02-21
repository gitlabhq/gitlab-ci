class Build < ActiveRecord::Base
  belongs_to :project

  attr_accessible :project_id, :ref, :sha, :before_sha,
    :status, :finished_at, :trace, :started_at

  validates :sha, presence: true
  validates :ref, presence: true
  validates :status, presence: true

  scope :latest_sha, where("id IN(SELECT MAX(id) FROM #{self.table_name} group by sha)")

  scope :running, ->() { where(status: "running") }
  scope :pending, ->() { where(status: "pending") }
  scope :success, ->() { where(status: "success") }
  scope :failed,  ->() { where(status: "failed")  }

  def self.last_month
    where('created_at > ?', Date.today - 1.month)
  end

  state_machine :status, initial: :pending do
    event :run do
      transition pending: :running
    end

    event :drop do
      transition running: :failed
    end

    event :success do
      transition running: :success
    end

    event :cancel do
      transition [:pending, :running] => :canceled
    end

    after_transition :pending => :running do |build, transition|
      build.update_attributes started_at: Time.now
    end

    after_transition any => [:success, :failed, :canceled] do |build, transition|
      build.update_attributes finished_at: Time.now
    end

    state :pending, value: 'pending'
    state :running, value: 'running'
    state :failed, value: 'failed'
    state :success, value: 'success'
    state :canceled, value: 'canceled'
  end

  def compare?
    gitlab? && before_sha
  end

  def gitlab?
    project.gitlab?
  end

  def ci_skip?
    !!(commit.message =~ /(\[ci skip\])/)
  end

  def git_author_name
    commit.author.name
  rescue
    nil
  end

  def git_commit_message
    commit.message
  rescue
    nil
  end

  def commit
    @commit ||= project.last_commit(self.sha)
  end

  def write_trace(trace)
    self.reload
    sanitized_output = sanitize_build_output(trace)
    update_attributes(trace: sanitized_output)
  end

  def short_before_sha
    before_sha[0..8]
  end

  def short_sha
    sha[0..8]
  end

  def trace_html
    if trace.present?
      Ansi2html::convert(compose_output)
    else
      ''
    end
  end

  def sanitize_build_output(output)
    GitlabCi::Encode.encode!(output)
  end

  def read_tmp_file
    content = if tmp_file && File.readable?(tmp_file)
                File.read(tmp_file)
              end

    content ||= ''
  end

  def compose_output
    output = trace

    if running?
      sanitized_output = sanitize_build_output(read_tmp_file)
      output << sanitized_output if sanitized_output.present?
    end

    output
  end

  def to_param
    sha
  end

  def started?
    !pending? && !canceled? && started_at
  end

  def active?
    running? || pending?
  end

  def set_file path
    self.tmp_file = path
    self.save
  end
end



# == Schema Information
#
# Table name: builds
#
#  id          :integer(4)      not null, primary key
#  project_id  :integer(4)
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text(2147483647
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#

