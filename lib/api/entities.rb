module GitlabCi
  module Entities
    class Project < Grape::Entity
      expose :id
      expose :name
      expose :path
      expose :scripts
      expose :default_ref
      expose :gitlab_url
      expose :token
      expose :always_build
      expose :polling_interval
      expose :timeout
      expose :public
      expose :created_at
    end
  end
end
