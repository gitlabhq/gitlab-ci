require 'digest/md5'

module User::Github
  def github?
    user_oauth_account.present? && user_oauth_account.github?
  end

  def github_login
    user_oauth_account.name if github?
  end

  def github_session
    if github?
      @github_session ||= Octokit::Client.new(:login => user_oauth_account.name,
                                              :oauth_token => user_oauth_account.token)
    end
  end

  def github_organization_names
    if github?
      github_session.orgs.map{|i| i["login"] }
    end
  end

  def github_team_ids
    if github?
      github_organization_names.map! do |login|
        github_session.get("/orgs/#{login}/teams").map{|i| i.id }
      end.flatten!
    end
  end

  def github_repositories
    if github?
      github_session.get('/user/repos', type:"all")
    end
  end

  def github_team_repositories
    if github?
      github_team_ids.map do |team_id|
        github_session.get("/teams/#{team_id}/repos")
      end.flatten.uniq_by{|i| i.id }
    end
  end
end
