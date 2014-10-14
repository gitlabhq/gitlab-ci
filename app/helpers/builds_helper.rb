module BuildsHelper
  def build_ref_link build
    if build.gitlab?
      gitlab_ref_link build.project, build.ref
    else
      build.ref
    end
  end

  def build_compare_link build
    if build.gitlab?
      gitlab_compare_link build.project, build.short_before_sha, build.short_sha
    end
  end

  def build_commit_link build
    if build.gitlab?
      gitlab_commit_link build.project, build.short_sha
    else
      build.short_sha
    end
  end

  def build_link build
    link_to(build.short_sha, project_build_path(build.project, build))
  end

  def build_url(build)
    project_build_url(build.project, build)
  end

  def build_group_url(build_group)
    project_build_group_url(build_group.project, build_group)
  end

  def build_or_build_group_url(build_group)
    if build_group.is_a? BuildGroup
      if build_group.one?
        build_url(build_group.builds.first)
      else
        build_group_url(build_group)
      end
    elsif build_group.is_a? Build
      build_url(build_group)
    else
      nil
    end
  end

  def build_or_build_group_link(build_group)
    if build_group.is_a? BuildGroup
      link_to(build_group.short_sha, build_or_build_group_url(build_group))
    elsif build_group.is_a? Build
      build_link(build_group)
    else
      nil
    end
  end

  def build_project_url(build)
    project_url(build.project)
  end
end
