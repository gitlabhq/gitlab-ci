class Network
  include HTTParty

  def authenticate(url, api_opts)
    opts = {
      body: api_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    response = self.class.post(url + api_prefix + 'session.json', opts)

    if response.code == 201
      response.parsed_response
    else
      nil
    end
  end

def projects(url, api_opts, scope = :owned)
    per_page = 100
    page = 1

    query = if scope == :owned
             'projects/owned.json'
            else
             'projects.json'
            end

    combined_response = []
    page = 1

    while true
      opts = {
        query: api_opts.merge(per_page: per_page, page: page),
        headers: {"Content-Type" => "application/json"},
      }
      response = self.class.get(url + api_prefix + query, opts)

      if response.code == 200
        combined_response += response.parsed_response
        page += 1

        if response.parsed_response.length < per_page
          break
        end
      else
        break
      end
    end

    if combined_response
      combined_response
    else
      nil
    end
  end
  
  def add_deploy_key(url, project_id, api_opts)
    opts = {
      body: api_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    response = self.class.post(url + api_prefix + "projects/#{project_id}/keys.json", opts)

    if response.code == 201
      response.parsed_response
    else
      nil
    end
  end

  private

  def api_prefix
    '/api/v3/'
  end
end
