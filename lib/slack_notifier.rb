# Wrapper class for Slack notifications
require 'slack/post'

module Slack
  class Notifier
    class << self
      def build_fail_slack_post(build)
        post(build, "#{slack_text(build)} failed")
      end

      def build_success_slack_post(build)
        post(build, "#{slack_text(build)} passed")
      end

      def slack_text(build)
        "#{build.project.name}: <" +
        Rails.application.routes.url_helpers.project_build_url(
          build.project, build,
          host: "gitlab-ci-dev.polidea.com", protocol: 'https'
        ) +
        "|build> of #{build.ref} by #{build.git_author_name}"
      end

      def post(build, slack_string)
        project = build.project
        Slack::Post.configure(
          subdomain: project.slack_notification_subdomain,
          token:     project.slack_notification_token,
          username:  project.slack_notification_username)
        Slack::Post.post(slack_string, project.slack_notification_channel)
      end
    end
  end
end
