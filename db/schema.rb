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

ActiveRecord::Schema.define(version: 20141001132129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: true do |t|
    t.integer  "project_id"
    t.string   "ref"
    t.string   "status"
    t.datetime "finished_at"
    t.text     "trace"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha"
    t.datetime "started_at"
    t.string   "tmp_file"
    t.string   "before_sha"
    t.text     "push_data"
    t.integer  "runner_id"
    t.float    "coverage"
  end

  add_index "builds", ["project_id"], name: "index_builds_on_project_id", using: :btree
  add_index "builds", ["runner_id"], name: "index_builds_on_runner_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                                     null: false
    t.integer  "timeout",                  default: 1800,  null: false
    t.text     "scripts",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "default_ref"
    t.string   "gitlab_url"
    t.boolean  "always_build",             default: false, null: false
    t.integer  "polling_interval"
    t.boolean  "public",                   default: false, null: false
    t.string   "ssh_url_to_repo"
    t.integer  "gitlab_id"
    t.boolean  "allow_git_fetch",          default: true,  null: false
    t.string   "email_recipients",         default: "",    null: false
    t.boolean  "email_add_committer",      default: true,  null: false
    t.boolean  "email_only_broken_builds", default: true,  null: false
    t.string   "skip_refs"
    t.string   "coverage_regex"
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
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "web_hooks", force: true do |t|
    t.string   "url",        null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
