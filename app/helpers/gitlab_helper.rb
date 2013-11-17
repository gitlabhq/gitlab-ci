module GitlabHelper
  def gitlab_ref_link project, ref
    gitlab_url = project.gitlab_url.dup
    gitlab_url << "/commits/#{ref}"
    link_to ref, gitlab_url
  end

  def gitlab_compare_link project, before, after
    gitlab_url = project.gitlab_url.dup
    gitlab_url << "/compare/#{before}...#{after}"

    link_to "#{before}...#{after}", gitlab_url
  end

  def gitlab_commit_link project, sha
    gitlab_url = project.gitlab_url.dup
    gitlab_url << "/commit/#{sha}"
    link_to sha, gitlab_url
  end

  def gitlab_issue_create_link test_step, project
    gitlab_url = project.gitlab_url.dup
    gitlab_url << "/issues/new?issue[title]=Test: #{test_step.title}&issue[description]=#{test_step.error_message}"
    link_to '<i class="icon-plus"></i> Create Issue'.html_safe, gitlab_url, class: 'btn'
  end
end
