class MigrateCiTables < ActiveRecord::Migration
  def up
    rename_table :application_settings, :ci_application_settings
    rename_table :builds, :ci_builds
    rename_table :commits, :ci_commits
    rename_table :events, :ci_events
    rename_table :jobs, :ci_jobs
    rename_table :projects, :ci_projects
    rename_table :runner_projects, :ci_runner_projects
    rename_table :runners, :ci_runners
    rename_table :services, :ci_services
    rename_table :tags, :ci_tags
    rename_table :taggings, :ci_taggings
    rename_table :trigger_requests, :ci_trigger_requests
    rename_table :triggers, :ci_triggers
    rename_table :variables, :ci_variables
    rename_table :web_hooks, :ci_web_hooks
  end
end
