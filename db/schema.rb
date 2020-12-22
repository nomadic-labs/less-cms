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

ActiveRecord::Schema.define(version: 2020_12_22_174044) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "websites", force: :cascade do |t|
    t.string "project_name"
    t.string "source_repo"
    t.string "firebase_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "firebase_config"
    t.string "slug"
    t.string "cloudflare_zone_id"
    t.text "environment_variables"
    t.json "firebase_config_staging"
    t.string "gatsby_env"
    t.string "firebase_env"
    t.string "custom_deploy_command"
    t.index ["slug"], name: "index_websites_on_slug", unique: true
  end

end
