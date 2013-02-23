module GithubHelper
  def github_project_url(project)
    "https://github.com/#{project.name}"
  end

  def link_to_github_build(build)
    link = "https://github.com/#{build.project.name}/commit/#{build.sha}"
    title = github_build_title(build)
    unless build.pull_request_number.blank?
      link = "https://github.com/#{build.project.name}/pull/#{build.pull_request_number}/files"
    end
    link_to title, link
  end

  def github_build_title(build)
    build.pull_request_ref.blank? ? build.ref : "#{build.pull_request_ref}:#{build.ref}"
  end
end
