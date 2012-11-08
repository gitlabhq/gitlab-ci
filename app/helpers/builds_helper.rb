module BuildsHelper
  def gitlab_build_compare_link build, project
    gitlab_url = project.gitlab_url

    prev_build = project.builds.where("id < #{build.id}").order('id desc').first

    compare_link = prev_build && prev_build.sha != build.sha

    if compare_link
      gitlab_url << "/compare/#{prev_build.short_sha}...#{build.short_sha}"
      link_to "Compare #{prev_build.short_sha}...#{build.short_sha}", gitlab_url
    else
      gitlab_url << "/commit/#{build.short_sha}"
      link_to "#{build.short_sha}", gitlab_url
    end
  end
end
