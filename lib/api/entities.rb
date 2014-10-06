module API
  module Entities
    class Build < Grape::Entity
      expose :id, :commands, :ref, :sha, :project_id, :repo_url, :before_sha, :allow_git_fetch, :project_name
      expose :ref_type
      expose :labels
    end

    class Runner < Grape::Entity
      expose :id, :token
    end

    class Project < Grape::Entity
      expose :id, :name, :timeout, :scripts, :token, :default_ref, :gitlab_url, :always_build, :polling_interval, :public, :ssh_url_to_repo, :gitlab_id
      expose :labels
      expose :build_method
      expose :travis_environment
    end

    class RunnerProject < Grape::Entity
      expose :id, :project_id, :runner_id
    end
  end
end
