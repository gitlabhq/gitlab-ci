module API
  module Helpers
    PRIVATE_TOKEN_PARAM = :private_token
    PRIVATE_TOKEN_HEADER = "HTTP_PRIVATE_TOKEN"

    def current_user
      @current_user ||= begin
        options = {
          :private_token => (params[PRIVATE_TOKEN_PARAM] || env[PRIVATE_TOKEN_HEADER]),
          :url => params[:url]
        }
        UserSession.new.authenticate_by_token(options)
      end
    end

    def current_runner
      @runner ||= Runner.find_by_token(params[:token])
    end

    def authenticate!
      forbidden! unless current_user
    end

    def authenticate_runners!
      forbidden! unless params[:token] == GitlabCi::REGISTRATION_TOKEN
    end

    def authenticate_runner!
      forbidden! unless current_runner
    end

    def authenticate_project_token!(project)
      forbidden! unless project.valid_token?(params[:project_token])
    end

    # Checks the occurrences of required attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (required) - A hash consisting of keys that must be present
    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) unless params[key].present?
      end
    end

    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if params[key].present?
      end
      attrs
    end

    # error helpers

    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end

    def bad_request!(attribute)
      message = ["400 (Bad request)"]
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end

    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def not_allowed!
      render_api_error!('Method Not Allowed', 405)
    end

    def render_api_error!(message, status)
      error!({'message' => message}, status)
    end

    private

    def abilities
      @abilities ||= begin
                       abilities = Six.new
                       abilities << Ability
                       abilities
                     end
    end
  end
end
