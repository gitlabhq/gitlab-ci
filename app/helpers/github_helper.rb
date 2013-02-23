module GithubHelper
  def github_project_url(project)
    "https://github.com/#{project.name}"
  end

  def link_to_github_build(build)
    link = "https://github.com/#{build.project.name}/commit/#{build.sha}"
    title = github_build_title(build)
    ico = "icon-arrow-right"
    unless build.pull_request_number.blank?
      link = "https://github.com/#{build.project.name}/pull/#{build.pull_request_number}/files"
      ico = "icon-share-alt"
    end
    raw("#{title} " + link_to(%{ <i class="#{ico}"></i> }.html_safe, link))
  end

  def github_build_title(build)
    build.pull_request_ref.blank? ? build.ref : "#{build.pull_request_ref}:#{build.ref}"
  end
end
