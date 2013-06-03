module API
  module Entities
    class Build < Grape::Entity
      expose :id, :commands, :path, :ref, :sha, :project_id, :repo_url
    end

    class Runner < Grape::Entity
      expose :id, :token
    end
  end
end
