# Wrapper class for Slack notifications
require 'slack/post'

module Slack
  class Notifier
    class << self
      def build_started_slack_post(build)
        text = build_text(build, "started")
        fields = [{}]

        unless build.one?
          build.build_group.builds.each do |other_build|
            fields << {
                title: "Variant #{other_build.build_concurrent_id}",
                value: "Check <#{build_url(other_build)}|build logs> for #{other_build.matrix_attributes_formatted}"
            }
          end
        end

        post(build, text, {
                      fallback: text,
                      text: text,
                      color: "warning",
                      fields: fields
                  })
      end
      
      def build_fail_slack_post(build)
        text = build_text(build, "failed")
        fields = [{}]

        unless build.one?
          build.build_group.builds.failed.each do |other_build|
            fields << {
                title: "Variant #{other_build.build_concurrent_id}",
                value: "Check <#{build_url(other_build)}|build logs> for #{other_build.matrix_attributes_formatted}"
            }
          end
        end

        post(build, text, {
                      fallback: text,
                      text: text,
                      color: "danger",
                      fields: fields
                  })
      end

      def build_success_slack_post(build)
        text = build_text(build, "passed in #{build.build_group.duration} second(s)")
        fields = [{}]

        post(build, text, {
                      fallback: text,
                      text: text,
                      color: "good",
                      fields: fields
                  })
      end

      def post(build, slack_string, opts={})
        begin
          project = build.project
          Slack::Post.configure(
            webhook:   project.slack_notification_webhook,
            username:  'GitLab CI')
          Slack::Post.post(slack_string, project.slack_notification_channel, opts)
        rescue
          return false
        end
      end

      private

      def build_text(build, message)
        build_type = build.tag? ? "Tagged build" : "Build"
        "<#{project_url(build.project)}|#{build.project.name}>: #{build_type} <#{build_or_build_group_url(build)}|\##{build.build_group.build_id}> (<#{build_ref_link(build)}|#{build.short_sha}>) of #{build.ref} by #{build.git_author_name} #{message}"
      end

      def build_or_build_group_url(build)
        if build.one?
          build_url(build)
        else
          build_group_url(build.build_group)
        end
      end

      def project_url(project)
        Rails.application.routes.url_helpers.project_url(
            project,
            host: Settings.gitlab_ci['host'], protocol: Settings.gitlab_ci['https'] ? "https" : "http", port: Settings.gitlab_ci['port']
        )
      end

      def build_url(build)
        Rails.application.routes.url_helpers.project_build_url(
            build.project, build,
            host: Settings.gitlab_ci['host'], protocol: Settings.gitlab_ci['https'] ? "https" : "http", port: Settings.gitlab_ci['port']
        )
      end

      def build_group_url(build_group)
        Rails.application.routes.url_helpers.project_build_group_url(
            build_group.project, build_group,
            host: Settings.gitlab_ci['host'], protocol: Settings.gitlab_ci['https'] ? "https" : "http", port: Settings.gitlab_ci['port']
        )
      end

      def build_ref_link(build)
        if build.gitlab?
          "#{build.project.gitlab_url}/commits/#{build.ref}"
        else
          build.ref
        end
      end
    end
  end
end
