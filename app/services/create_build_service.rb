class CreateBuildService
  def execute(project, params)
    commit = Commit.where(project: project).where(sha: params[:after]).first
    commit ||= CreateCommitService.new.execute(project, params)

    if commit.persisted?
      commit.builds.create
    else
      commit.builds.new
    end
  end
end
