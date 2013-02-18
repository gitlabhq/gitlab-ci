require 'digest/md5'

class GithubProject < Project
  belongs_to :user

  validates :user_id, :github_repo_id, :clone_url,
            :public_key, :private_key, :presence => true
  validates :github_repo_id, :public_key, :uniqueness => true

  class << self
    def build_for_repo(user, repo_params)
      project = GithubProject.new.tap do |p|
        p.set_default_values
        p.generate_ssh_keys
        p.user           = user
        p.github_repo_id = repo_params[:id]
        p.name           = repo_params[:name]
        p.scripts        = p.path + "/.ci_runner"
        p.timeout        = 1800
        p.default_ref    = 'master'
        p.clone_url      = repo_params[:git]
        p.path           = p.path
      end
      project
    end

    def store_repo_path
      @store_repo_path = File.expand_path Settings.github.store_repo_path.gsub(/\:rails_root/, Rails.root.to_s)
    end

    def model_name
      Project.model_name
    end
  end

  def generate_ssh_keys
    ssh_key = SSHKey.generate(type: "RSA", bits: 1024, comment: deploy_key_name)
    self.public_key  = ssh_key.ssh_public_key.strip
    self.private_key = ssh_key.private_key.strip
    self
  end



  def path
    self.class.store_repo_path + "/#{name}"
  end

  def save_with_github_repo!
    transaction do
      save!
      remove_existing_deploy_keys!
      add_deploy_key!
      remove_existing_hooks!
      add_hook!
    end
  end

  def add_deploy_key!
    session.add_deploy_key(name, deploy_key_name, public_key)
  end

  def add_hook!
    config = {
      url: hook_url,
      secret: token,
      content_type: "json"
    }
    options = { events: ["push", "pull_request"] }
    session.create_hook(name, "web", config, options)
  end

  def remove_existing_hooks!
    hooks = session.hooks(name).select do |hook|
      hook.config.url =~ /^#{Regexp.escape hook_url_prefix}/
    end
    hooks.each do |hook|
      session.remove_hook(name, hook.id)
    end
    hooks
  end

  def remove_existing_deploy_keys!
    keys = session.deploy_keys(name).select do |key|
      key.title == deploy_key_name
    end
    keys.each do |key|
      session.remove_deploy_key(name, key.id)
    end
    keys
  end

  def deploy_key_name
    Settings.hostname
  end

  def hook_url
    "#{hook_url_prefix}/projects/#{id}/build?token=#{token}"
  end

  def self.git_ssh_command
    "#{Rails.root.to_s}/script/ci_git_ssh"
  end

  def store_ssh_keys!
    FileUtils.mkdir_p File.dirname(ssh_key_path)
    FileUtils.chmod 0700, File.dirname(ssh_key_path)
    File.open(ssh_key_path, "w", 0600) do |io|
      io.write private_key
    end
    ssh_key_path
  end

  def clean_ssh_keys!
    FileUtils.rm_f ssh_key_path
    ssh_key_path
  end

  def last_ref_sha ref
    ENV['GIT_SSH'] = self.class.git_ssh_command
    ENV['GITLAB_CI_KEY'] = store_ssh_keys!
    last_ref = if repo_present?
                 super(ref)
               else
                 `git ls-remote --heads #{clone_url} refs/heads/#{ref}`.split(" ").first
               end
    clean_ssh_keys!
    last_ref
  end

  private
    def ssh_key_path
      @ssh_key_path ||= Rails.root.join("tmp", "keys", Rails.env, id.to_s).to_s
    end

    def hook_url_prefix
      "http://#{Settings.hostname}"
    end

    def session
      user.github_session
    end

end

# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)     not null
#  path             :string(255)     not null
#  timeout          :integer(4)      default(1800), not null
#  scripts          :text            default(""), not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token            :string(255)
#  default_ref      :string(255)
#  gitlab_url       :string(255)
#  always_build     :boolean(1)      default(FALSE), not null
#  polling_interval :integer(4)
#  type             :string(255)
#  user_id          :integer(4)
#

