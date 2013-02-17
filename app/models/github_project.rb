require 'digest/md5'

class GithubProject < Project
  belongs_to :user

  validates :user_id, :github_repo_id, :clone_url,
            :public_key, :private_key, :presence => true
  validates :github_repo_id, :public_key, :uniqueness => true

  class << self
    def build_for_repo(user, repo_params)
      project = GithubProject.new.tap do |p|
        ssh_key = SSHKey.generate(:type => "RSA", :bits => 1024, :comment => p.deploy_key_name)
        p.set_default_values
        p.user           = user
        p.github_repo_id = repo_params[:id]
        p.name           = repo_params[:name]
        p.path           = store_repo_path + "/#{p.name}"
        p.scripts        = Rails.root.join("script", 'ci_runner').to_s
        p.timeout        = 1800
        p.default_ref    = 'master'
        p.clone_url      = repo_params[:git]
        p.public_key     = ssh_key.ssh_public_key.strip
        p.private_key    = ssh_key.private_key.strip
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

  private
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

