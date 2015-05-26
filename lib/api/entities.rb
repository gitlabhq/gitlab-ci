module API
  module Entities
    class Commit < Grape::Entity
      expose :id, :ref, :sha, :project_id, :before_sha, :created_at
      expose :status, :finished_at, :duration
      expose :git_commit_message, :git_author_name, :git_author_email
      expose :builds
    end

    class Build < Grape::Entity
      expose :id, :commands, :path, :ref, :sha, :project_id, :repo_url,
        :before_sha, :timeout, :allow_git_fetch, :project_name,
        :cache_pattern_list
    end

    class Runner < Grape::Entity
      expose :id, :token
    end

    class Project < Grape::Entity
      expose :id, :name, :timeout, :token, :default_ref, :gitlab_url, :path,
        :always_build, :polling_interval, :public, :ssh_url_to_repo, :gitlab_id
    end

    class RunnerProject < Grape::Entity
      expose :id, :project_id, :runner_id
    end

    class WebHook < Grape::Entity
      expose :id, :project_id, :url
    end

    class Job < Grape::Entity
      expose :id, :project_id, :commands, :active, :name, :build_branches,
        :build_tags, :tags, :job_type, :tag_list
    end

    class DeployJob < Grape::Entity
      expose :id, :project_id, :commands, :active, :name,
        :refs, :tags, :job_type, :refs, :tag_list
    end
  end
end
