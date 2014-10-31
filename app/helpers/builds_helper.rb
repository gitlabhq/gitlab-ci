module BuildsHelper
  def build_ref_link build
    if build.commit.gitlab?
      gitlab_ref_link build.project, build.ref
    else
      build.ref
    end
  end

  def build_compare_link build
    if build.commit.gitlab?
      gitlab_compare_link build.project, build.commit.short_before_sha, build.short_sha
    end
  end

  def build_commit_link build
    if build.commit.gitlab?
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
end
