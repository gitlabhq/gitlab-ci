class Network
  include HTTParty

  API_PREFIX = '/api/v3/'

  def authenticate(url, api_opts)
    opts = {
      body: api_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'session.json')
    response = self.class.post(endpoint, opts)

    if response.code == 201
      response.parsed_response
    else
      nil
    end
  end

  def authenticate_by_token(url, api_opts)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'user.json')
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
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

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def project(url, api_opts, project_id)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}.json"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def commit_for_ref_or_sha(url, project_id, token, ref_name = 'master')
    commits = commits_for_ref(url, project_id, token, ref_name)
    ref_name = commits[0]["id"] if commits and commits.length > 0
    return commit_for_sha(url, project_id, token, ref_name)
  end

  def commits_for_ref(url, project_id, token, ref_name = 'master')
    opts = {
        headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/repository/commits?private_token=#{token}&ref_name=#{ref_name}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def commit_for_sha(url, project_id, token, sha)
    opts = {
        headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/repository/commits/#{sha}?private_token=#{token}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def enable_ci(url, project_id, ci_opts, token)
    opts = {
      body: ci_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/services/gitlab-ci.json?private_token=#{token}"
    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.put(endpoint, opts)

    if response.code == 200
      true
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

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def create_tag(url, project_id, token, tag_opts)
    tag_opts.merge!(private_token: token)

    opts = {
        body: tag_opts.to_json,
        headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/repository/tags"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.post(endpoint, opts)

    if response.code == 200 || response.code == 201
      response.parsed_response
    elsif response.code == 400
      raise response.parsed_response['message']
    else
      raise response.code
    end
  end
end
