module Emails
  module Builds
    def build_fail_email(build_id)
      @build = Build.find(build_id)
      @project = @build.project
      mail(to: @build.git_author_name, subject: subject("Build failed for #{@project.name}", @build.short_sha))
    end

    def build_success_email(build_id)
      @build = Build.find(build_id)
      @project = @build.project
      mail(to: @build.git_author_name, subject: subject("Build success for #{@project.name}", @build.short_sha))
    end
  end
end
