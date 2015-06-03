# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150602000240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: true do |t|
    t.integer  "project_id"
    t.string   "status"
    t.datetime "finished_at"
    t.text     "trace"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.integer  "runner_id"
    t.integer  "commit_id"
    t.float    "coverage"
    t.text     "commands"
    t.integer  "job_id"
  end

  add_index "builds", ["commit_id"], name: "index_builds_on_commit_id", using: :btree
  add_index "builds", ["project_id", "commit_id"], name: "index_builds_on_project_id_and_commit_id", using: :btree
  add_index "builds", ["project_id"], name: "index_builds_on_project_id", using: :btree
  add_index "builds", ["runner_id"], name: "index_builds_on_runner_id", using: :btree

  create_table "commits", force: true do |t|
    t.integer  "project_id"
    t.string   "ref"
    t.string   "sha"
    t.string   "before_sha"
    t.text     "push_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["project_id", "sha"], name: "index_commits_on_project_id_and_sha", using: :btree
  add_index "commits", ["project_id"], name: "index_commits_on_project_id", using: :btree
  add_index "commits", ["sha"], name: "index_commits_on_sha", using: :btree

  create_table "events", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "is_admin"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["is_admin"], name: "index_events_on_is_admin", using: :btree
  add_index "events", ["project_id"], name: "index_events_on_project_id", using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "project_id",                          null: false
    t.text     "commands"
    t.boolean  "active",         default: true,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "build_branches", default: true,       null: false
    t.boolean  "build_tags",     default: false,      null: false
    t.string   "job_type",       default: "parallel"
    t.string   "refs"
    t.datetime "deleted_at"
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree
  add_index "jobs", ["project_id"], name: "index_jobs_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                                     null: false
    t.integer  "timeout",                  default: 3600,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "default_ref"
    t.string   "path"
    t.boolean  "always_build",             default: false, null: false
    t.integer  "polling_interval"
    t.boolean  "public",                   default: false, null: false
    t.string   "ssh_url_to_repo"
    t.integer  "gitlab_id"
    t.boolean  "allow_git_fetch",          default: true,  null: false
    t.string   "email_recipients",         default: "",    null: false
    t.boolean  "email_add_pusher",         default: true,  null: false
    t.boolean  "email_only_broken_builds", default: true,  null: false
    t.string   "skip_refs"
    t.string   "coverage_regex"
    t.boolean  "shared_runners_enabled",   default: false
  end

  create_table "runner_projects", force: true do |t|
    t.integer  "runner_id",  null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "runner_projects", ["project_id"], name: "index_runner_projects_on_project_id", using: :btree
  add_index "runner_projects", ["runner_id"], name: "index_runner_projects_on_runner_id", using: :btree

  create_table "runners", force: true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.datetime "contacted_at"
    t.boolean  "active",       default: true,  null: false
    t.boolean  "is_shared",    default: false
    t.string   "name"
    t.string   "version"
    t.string   "revision"
    t.string   "platform"
    t.string   "architecture"
  end

  create_table "services", force: true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "project_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: false, null: false
    t.text     "properties"
  end

  add_index "services", ["project_id"], name: "index_services_on_project_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "web_hooks", force: true do |t|
    t.string   "url",        null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
