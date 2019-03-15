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

ActiveRecord::Schema.define(version: 2019_03_15_010158) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "websites", force: :cascade do |t|
    t.string "project_name"
    t.string "source_repo"
    t.string "firebase_api_key"
    t.string "firebase_auth_domain"
    t.string "firebase_database_url"
    t.string "firebase_project_id"
    t.text "firebase_service_account_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token"
    t.json "firebase_config"
  end

end
