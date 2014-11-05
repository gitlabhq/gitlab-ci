class CreateBuildsService
  def execute(project, params)
    commit = Commit.where(project: project).where(sha: params[:after]).first
    commit ||= CreateCommitService.new.execute(project, params)
    commit.create_builds
  end
end
