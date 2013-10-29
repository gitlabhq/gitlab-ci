module API
  module Entities
    class Build < Grape::Entity
      expose :id, :commands, :path, :ref, :sha, :project_id, :repo_url, :before_sha, :timeout, :allow_git_fetch, :project_name
    end

    class Runner < Grape::Entity
      expose :id, :token
    end

    class Project < Grape::Entity
      expose :id, :name, :timeout, :scripts, :token, :default_ref, :gitlab_url, :always_build, :polling_interval, :public, :ssh_url_to_repo, :gitlab_id
    end

    class RunnerProject < Grape::Entity
      expose :id, :project_id, :runner_id
    end
  end
end
