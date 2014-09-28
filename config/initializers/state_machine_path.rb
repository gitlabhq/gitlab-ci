# https://github.com/pluginaweek/state_machine/pull/275
module StateMachine
  module Integrations
     module ActiveModel
        public :around_validation
     end
  end
end
