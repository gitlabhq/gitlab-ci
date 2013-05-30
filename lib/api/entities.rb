module API
  module Entities
    class Build < Grape::Entity
      expose :id, :commands, :path, :ref, :sha
    end
  end
end
