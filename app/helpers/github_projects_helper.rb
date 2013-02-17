module GithubProjectsHelper
  def github_repo_display?(repo)
    @all_projects_ids ||= GithubProject.select(:github_repo_id).all.map(&:github_repo_id)
    !@all_projects_ids.include?(repo.id)
  end
end
