class Network
  class UnauthorizedError < StandardError; end

  include HTTParty

  API_PREFIX = '/api/v3/'

  def authenticate(url, api_opts)
    opts = {
      body: api_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'user')
    response = self.class.get(endpoint, opts)

    build_response(response)
  end

  def authenticate_by_token(url, api_opts)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'user.json')
    response = self.class.get(endpoint, opts)

    build_response(response)
  end


  def projects(url, api_opts, scope = :owned)
    # Dont load archived projects
    api_opts.merge!(archived: false)

    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = if scope == :owned
             'projects/owned.json'
            else
             'projects.json'
            end

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    build_response(response)
  end

  def project(url, api_opts, project_id)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}.json"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    build_response(response)
  end

  def project_hooks(url, api_opts, project_id)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/hooks.json"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    build_response(response)
  end

  def enable_ci(url, project_id, ci_opts, token)
    opts = {
      body: ci_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/services/gitlab-ci.json?private_token=#{token}"
    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.put(endpoint, opts)

    case response.code
    when 200
      true
    when 401
      raise UnauthorizedError
    else
      nil
    end
  end

  def disable_ci(url, project_id, token)
    opts = {
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/services/gitlab-ci.json?private_token=#{token}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.delete(endpoint, opts)

    build_response(response)
  end

  private

  def build_response(response)
    case response.code
    when 200
      response.parsed_response
    when 401
      raise UnauthorizedError
    else
      nil
    end
  end
end
