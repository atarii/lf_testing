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

ActiveRecord::Schema.define(version: 20151021092401) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "atg_address", primary_key: "Id", force: :cascade do |t|
    t.string "locale",       limit: 255, default: ""
    t.string "address1",     limit: 255, default: ""
    t.string "address2",     limit: 255, default: ""
    t.string "city",         limit: 255, default: ""
    t.string "state",        limit: 255, default: ""
    t.string "postal",       limit: 255, default: ""
    t.string "phone_number", limit: 255, default: ""
  end

  create_table "atg_cabo_filter_list", force: :cascade do |t|
    t.string "locale", limit: 12,               null: false
    t.string "name",   limit: 255, default: "", null: false
    t.string "href",   limit: 255, default: "", null: false
    t.string "type",   limit: 255, default: "", null: false
  end

  create_table "atg_code_type", id: false, force: :cascade do |t|
    t.string "id",   limit: 255
    t.string "type", limit: 255
  end

  create_table "atg_configurations", force: :cascade do |t|
    t.text     "data",       limit: -1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "atg_credit", primary_key: "Id", force: :cascade do |t|
    t.string "card_type",   limit: 100, default: ""
    t.string "card_number", limit: 50,  default: ""
  end

  create_table "atg_filter_list", force: :cascade do |t|
    t.string "locale", limit: 12,               null: false
    t.string "name",   limit: 255, default: "", null: false
    t.string "href",   limit: 255, default: "", null: false
    t.string "type",   limit: 255, default: "", null: false
  end

  create_table "atg_lfc_filter_list", force: :cascade do |t|
    t.string "locale", limit: 12,               null: false
    t.string "name",   limit: 255, default: "", null: false
    t.string "href",   limit: 255, default: "", null: false
    t.string "type",   limit: 255, default: "", null: false
  end

  create_table "atg_moas", id: false, force: :cascade do |t|
    t.date    "golivedate",                                      null: false
    t.string  "appstatus",             limit: 12,                null: false
    t.string  "prodnumber",            limit: 16,   default: "", null: false
    t.string  "sku",                   limit: 12,                null: false
    t.string  "shortname",             limit: 100,  default: "", null: false
    t.string  "longname",              limit: 100,  default: "", null: false
    t.string  "gender",                limit: 10,   default: "", null: false
    t.integer "agefrommonths",         limit: 4,    default: 0,  null: false
    t.integer "agetomonths",           limit: 4,    default: 0,  null: false
    t.string  "skills",                limit: 100,  default: "", null: false
    t.string  "curriculum",            limit: 50,   default: "", null: false
    t.string  "lfdesc",                limit: 2000, default: "", null: false
    t.string  "onesentence",           limit: 500,  default: ""
    t.string  "moreinfolb",            limit: 200,  default: "", null: false
    t.string  "moreinfotxt",           limit: 3500, default: "", null: false
    t.string  "platformcompatibility", limit: 150,  default: "", null: false
    t.string  "specialmsg",            limit: 500,               null: false
    t.string  "teaches",               limit: 150,  default: "", null: false
    t.string  "legaltop",              limit: 300,  default: "", null: false
    t.string  "legalbottom",           limit: 1000, default: "", null: false
    t.string  "licensed",              limit: 50,   default: "", null: false
    t.string  "licensors",             limit: 50,   default: "", null: false
    t.string  "language",              limit: 25,                null: false
    t.string  "pricetier",             limit: 25,                null: false
    t.string  "contenttype",           limit: 50,   default: "", null: false
    t.string  "trailer",               limit: 10,   default: "", null: false
    t.string  "trailerlink",           limit: 100,  default: "", null: false
    t.string  "trailersizes",          limit: 50,   default: "", null: false
    t.string  "screenshots",           limit: 2000, default: "", null: false
    t.string  "us",                    limit: 5,                 null: false
    t.string  "ca",                    limit: 5,                 null: false
    t.string  "uk",                    limit: 5,                 null: false
    t.string  "ie",                    limit: 5,                 null: false
    t.string  "au",                    limit: 5,                 null: false
    t.string  "row",                   limit: 5,                 null: false
    t.string  "fr_fr",                 limit: 5,                 null: false
    t.string  "fr_ca",                 limit: 5,                 null: false
    t.string  "fr_row",                limit: 5,    default: "", null: false
    t.string  "lpu",                   limit: 5,    default: "", null: false
    t.string  "lp3",                   limit: 5,    default: "", null: false
    t.string  "lp2",                   limit: 5,    default: "", null: false
    t.string  "lp1",                   limit: 5,    default: "", null: false
    t.string  "lgs",                   limit: 5,    default: "", null: false
    t.string  "lex",                   limit: 5,    default: "", null: false
    t.string  "lpr",                   limit: 5,    default: "", null: false
    t.string  "lfshoppingcartname",    limit: 200,  default: "", null: false
    t.string  "format",                limit: 100,  default: "", null: false
    t.string  "filesize",              limit: 300,               null: false
    t.string  "lfchar",                limit: 200,  default: "", null: false
    t.string  "publisher",             limit: 100,  default: "", null: false
    t.integer "length",                limit: 2,    default: 0,  null: false
    t.string  "highlights",            limit: 200,               null: false
    t.string  "learningdifference",    limit: 1000, default: "", null: false
    t.string  "details",               limit: 4000, default: "", null: false
    t.string  "miscnotes",             limit: 1000,              null: false
    t.string  "ymal",                  limit: 200
    t.string  "baseassetname",         limit: 255,               null: false
  end

  add_index "atg_moas", ["agefrommonths"], name: "agefrommonths_idx", using: :btree
  add_index "atg_moas", ["agetomonths"], name: "agetomonths_idx", using: :btree

  create_table "atg_moas_fr", id: false, force: :cascade do |t|
    t.date    "golivedate",                                      null: false
    t.string  "appstatus",             limit: 12,                null: false
    t.string  "prodnumber",            limit: 16,   default: "", null: false
    t.string  "sku",                   limit: 12,                null: false
    t.string  "shortname",             limit: 100,  default: "", null: false
    t.string  "longname",              limit: 100,  default: "", null: false
    t.string  "gender",                limit: 10,   default: "", null: false
    t.integer "agefrommonths",         limit: 4,    default: 0,  null: false
    t.integer "agetomonths",           limit: 4,    default: 0,  null: false
    t.string  "skills",                limit: 100,  default: "", null: false
    t.string  "curriculum",            limit: 50,   default: "", null: false
    t.string  "lfdesc",                limit: 2000, default: "", null: false
    t.string  "moreinfolb",            limit: 200,  default: "", null: false
    t.string  "moreinfotxt",           limit: 3500, default: "", null: false
    t.string  "platformcompatibility", limit: 150,  default: "", null: false
    t.string  "specialmsg",            limit: 255,               null: false
    t.string  "teaches",               limit: 150,  default: "", null: false
    t.string  "legaltop",              limit: 300,  default: "", null: false
    t.string  "legalbottom",           limit: 1000, default: "", null: false
    t.string  "licensed",              limit: 50,   default: "", null: false
    t.string  "licensors",             limit: 50,   default: "", null: false
    t.string  "language",              limit: 25,                null: false
    t.string  "pricetier",             limit: 25,                null: false
    t.string  "contenttype",           limit: 50,   default: "", null: false
    t.string  "trailer",               limit: 10,   default: "", null: false
    t.string  "trailerlink",           limit: 100,  default: "", null: false
    t.string  "trailersizes",          limit: 50,   default: "", null: false
    t.string  "screenshots",           limit: 2000, default: "", null: false
    t.string  "us",                    limit: 5,                 null: false
    t.string  "ca",                    limit: 5,                 null: false
    t.string  "uk",                    limit: 5,                 null: false
    t.string  "ie",                    limit: 5,                 null: false
    t.string  "au",                    limit: 5,                 null: false
    t.string  "row",                   limit: 5,                 null: false
    t.string  "fr_fr",                 limit: 5,                 null: false
    t.string  "fr_ca",                 limit: 5,                 null: false
    t.string  "fr_row",                limit: 5,    default: "", null: false
    t.string  "lpu",                   limit: 5,    default: "", null: false
    t.string  "lp3",                   limit: 5,    default: "", null: false
    t.string  "lp2",                   limit: 5,    default: "", null: false
    t.string  "lp1",                   limit: 5,    default: "", null: false
    t.string  "lgs",                   limit: 5,    default: "", null: false
    t.string  "lex",                   limit: 5,    default: "", null: false
    t.string  "lpr",                   limit: 5,    default: "", null: false
    t.string  "lfshoppingcartname",    limit: 200,  default: "", null: false
    t.string  "format",                limit: 100,  default: "", null: false
    t.string  "filesize",              limit: 100,  default: "", null: false
    t.string  "lfchar",                limit: 200,  default: "", null: false
    t.string  "publisher",             limit: 100,  default: "", null: false
    t.integer "length",                limit: 2,    default: 0,  null: false
    t.string  "highlights",            limit: 100,  default: "", null: false
    t.string  "learningdifference",    limit: 1000, default: "", null: false
    t.string  "details",               limit: 4000, default: "", null: false
    t.string  "miscnotes",             limit: 800,  default: "", null: false
    t.string  "onesentence",           limit: 255
    t.string  "baseassetname",         limit: 255,               null: false
  end

  add_index "atg_moas_fr", ["agefrommonths"], name: "agefrommonths_idx", using: :btree
  add_index "atg_moas_fr", ["agetomonths"], name: "agetomonths_idx", using: :btree

  create_table "atg_moas_fr_mapping", id: false, force: :cascade do |t|
    t.string "french",     limit: 255, default: ""
    t.string "english",    limit: 255, default: ""
    t.string "field_name", limit: 255, default: ""
  end

  create_table "atg_pricetier", force: :cascade do |t|
    t.string "locale",         limit: 12, null: false
    t.string "tier",           limit: 12, null: false
    t.string "price",          limit: 5,  null: false
    t.string "currencysymbol", limit: 25, null: false
  end

  create_table "atg_testcase", primary_key: "Id", force: :cascade do |t|
    t.string "friendlyname", limit: 255, default: "", null: false
    t.string "testcase",     limit: 255, default: "", null: false
    t.string "testsuite",    limit: 255, default: "", null: false
  end

  create_table "atg_testsuite", primary_key: "Id", force: :cascade do |t|
    t.string "friendlyname", limit: 255, default: "", null: false
    t.string "testcase_id",  limit: 255, default: "", null: false
    t.string "note",         limit: 255, default: "", null: false
  end

  create_table "atg_tracking", primary_key: "Id", force: :cascade do |t|
    t.string   "firstname",     limit: 255,   default: "", null: false
    t.string   "lastname",      limit: 255,   default: "", null: false
    t.string   "email",         limit: 255,   default: "", null: false
    t.string   "country",       limit: 10,    default: "", null: false
    t.string   "address1",      limit: 255,   default: "", null: false
    t.string   "credit_number", limit: 20,    default: "", null: false
    t.string   "exp_month",     limit: 2,     default: "", null: false
    t.string   "exp_year",      limit: 4,     default: "", null: false
    t.text     "order_id",      limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "atg_ultra_filter_list", force: :cascade do |t|
    t.string "locale", limit: 12,               null: false
    t.string "name",   limit: 255, default: "", null: false
    t.string "href",   limit: 255, default: "", null: false
    t.string "type",   limit: 255, default: "", null: false
  end

  create_table "atgs", force: :cascade do |t|
    t.string   "webdriver",    limit: 255
    t.string   "env",          limit: 255
    t.string   "locale",       limit: 255
    t.string   "exist_acc",    limit: 255
    t.string   "empty_acc",    limit: 255
    t.string   "testcase",     limit: 255
    t.string   "testrun",      limit: 255
    t.string   "testsuite",    limit: 255
    t.string   "resultname",   limit: 255
    t.string   "user_email",   limit: 255
    t.string   "release_date", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "case_suite_maps", force: :cascade do |t|
    t.integer  "suite_id",   limit: 4
    t.integer  "case_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      limit: 4
  end

  add_index "case_suite_maps", ["case_id"], name: "index_case_suite_maps_on_case_id", using: :btree
  add_index "case_suite_maps", ["suite_id"], name: "index_case_suite_maps_on_suite_id", using: :btree

  create_table "cases", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "script_path", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_queues", force: :cascade do |t|
    t.integer  "run_id",     limit: 4
    t.string   "email_list", limit: 1000
    t.datetime "created_at"
  end

  create_table "email_rollups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "repeat_min",  limit: 4
    t.datetime "start_time"
    t.datetime "from_time"
    t.string   "emails_list", limit: 255
    t.integer  "status",      limit: 3
    t.integer  "user_id",     limit: 4
  end

  create_table "env_versions", force: :cascade do |t|
    t.text     "services",   limit: -1
    t.datetime "updated_at"
  end

  create_table "outposts", force: :cascade do |t|
    t.string   "name",            limit: 100, null: false
    t.string   "silo",            limit: 50,  null: false
    t.string   "ip",              limit: 255, null: false
    t.string   "status",          limit: 255
    t.string   "status_url",      limit: 255
    t.string   "exec_url",        limit: 255
    t.text     "available_tests", limit: -1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "checked_at"
  end

  add_index "outposts", ["name"], name: "index_outposts_on_name", unique: true, using: :btree

  create_table "pins", force: :cascade do |t|
    t.string   "env",        limit: 10,  default: "", null: false
    t.string   "code_type",  limit: 5,   default: "", null: false
    t.string   "pin_number", limit: 20,  default: "", null: false
    t.string   "platform",   limit: 255, default: ""
    t.string   "location",   limit: 100, default: ""
    t.string   "amount",     limit: 5,   default: ""
    t.string   "currency",   limit: 5,   default: ""
    t.string   "status",     limit: 10,  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runs", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.datetime "date"
    t.decimal  "percent_pass",             precision: 10
    t.decimal  "case_count",               precision: 10
    t.string   "note",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data",         limit: -1
    t.string   "status",       limit: 15,                 null: false
    t.string   "location",     limit: 50
  end

  add_index "runs", ["user_id"], name: "index_runs_on_user_id", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.text     "data",        limit: -1
    t.datetime "start_date"
    t.integer  "repeat_min",  limit: 4
    t.string   "weekly",      limit: 255
    t.datetime "next_run"
    t.integer  "status",      limit: 3
    t.integer  "user_id",     limit: 4
    t.string   "location",    limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "lf_alias",   limit: 255
    t.string   "cust_type",  limit: 255
    t.string   "locale",     limit: 255
    t.string   "email",      limit: 255
    t.string   "customerid", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lf_pin",     limit: 255
    t.string   "type_pin",   limit: 255
    t.string   "locale_pin", limit: 255
    t.string   "env",        limit: 255
  end

  create_table "silos", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stations", id: false, force: :cascade do |t|
    t.string   "network_name", limit: 255, null: false
    t.string   "station_name", limit: 255
    t.string   "ip",           limit: 255
    t.integer  "port",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stations", ["network_name"], name: "index_stations_on_network_name", unique: true, using: :btree

  create_table "suite_maps", force: :cascade do |t|
    t.integer  "parent_suite_id", limit: 4
    t.integer  "child_suite_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",           limit: 4
  end

  create_table "suites", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "silo_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",       limit: 4
  end

  add_index "suites", ["silo_id"], name: "index_suites_on_silo_id", using: :btree

  create_table "tc_release_notes", force: :cascade do |t|
    t.text     "notes",      limit: -1
    t.string   "release",    limit: 100, null: false
    t.datetime "updated_at"
  end

  add_index "tc_release_notes", ["release"], name: "index_tc_release_notes_on_release", unique: true, using: :btree

  create_table "user_role_maps", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "role_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_role_maps", ["role_id"], name: "index_user_role_maps_on_role_id", using: :btree
  add_index "user_role_maps", ["user_id"], name: "index_user_role_maps_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "email",      limit: 255
    t.string   "password",   limit: 255
    t.boolean  "is_active",  limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ws_restfulcalls", force: :cascade do |t|
    t.string "callerid",         limit: 40
    t.string "session",          limit: 40
    t.string "devserial",        limit: 40
    t.string "platform",         limit: 10
    t.string "pkgid",            limit: 100
    t.string "licenseid",        limit: 15
    t.string "upload_data",      limit: 800
    t.string "upload_data_1",    limit: 800
    t.string "status",           limit: 5
    t.string "query_string",     limit: 200
    t.string "test_description", limit: 1000
    t.string "rest_service",     limit: 40
    t.string "Run",              limit: 10,   default: "Yes"
    t.string "env",              limit: 255
  end

  create_table "ws_restfulcalls_output", primary_key: "Id", force: :cascade do |t|
    t.integer "restfulcalls_id",               limit: 2,     default: 0,  null: false
    t.string  "restfulcalls_test_description", limit: 1000
    t.string  "rest_service",                  limit: 100,   default: "", null: false
    t.text    "data",                          limit: 65535
  end

end
