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

ActiveRecord::Schema.define(version: 20121128140328) do

  create_table "admin_notes", force: true do |t|
    t.string   "resource_id",     null: false
    t.string   "resource_type",   null: false
    t.integer  "admin_user_id"
    t.string   "admin_user_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_notes", ["admin_user_type", "admin_user_id"], name: "index_admin_notes_on_admin_user_type_and_admin_user_id"
  add_index "admin_notes", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "cities", force: true do |t|
    t.string   "city_name",                         null: false
    t.string   "local_name"
    t.string   "full_name"
    t.string   "metro_name"
    t.string   "country",                           null: false
    t.float    "lat"
    t.float    "lon"
    t.string   "bounds"
    t.string   "openinghours"
    t.text     "description"
    t.text     "fares"
    t.string   "openingyear"
    t.integer  "nstations"
    t.integer  "length"
    t.boolean  "public",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "scale"
    t.string   "offset"
    t.integer  "center_station_id"
    t.boolean  "local_names",       default: true
  end

  add_index "cities", ["city_name", "country"], name: "index_cities_on_city_name_and_country", unique: true
  add_index "cities", ["public"], name: "index_cities_on_public"

  create_table "connections", force: true do |t|
    t.integer  "station_id"
    t.integer  "target_id"
    t.integer  "line_id"
    t.integer  "city_id"
    t.float    "distance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
    t.string   "bezier"
  end

  add_index "connections", ["city_id"], name: "index_connections_on_city_id"
  add_index "connections", ["line_id"], name: "index_connections_on_line_id"
  add_index "connections", ["station_id", "target_id"], name: "index_connections_on_station_id_and_target_id", unique: true

  create_table "lines", force: true do |t|
    t.integer  "city_id",    null: false
    t.string   "name"
    t.string   "name_local"
    t.string   "color"
    t.string   "style"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lines", ["city_id"], name: "index_lines_on_city_id"

  create_table "lines_stations", force: true do |t|
    t.integer  "station_id"
    t.integer  "line_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lines_stations", ["city_id"], name: "index_lines_stations_on_city_id"
  add_index "lines_stations", ["station_id", "line_id"], name: "index_lines_stations_on_station_id_and_line_id", unique: true

  create_table "routes", force: true do |t|
    t.integer  "city_id",                    null: false
    t.integer  "source_id",                  null: false
    t.integer  "destination_id",             null: false
    t.text     "nodes"
    t.text     "edges"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "distance"
    t.text     "html"
    t.integer  "hits",           default: 0
  end

  add_index "routes", ["city_id"], name: "index_routes_on_city_id"
  add_index "routes", ["source_id", "destination_id"], name: "index_routes_on_source_id_and_destination_id"

  create_table "stations", force: true do |t|
    t.integer  "city_id"
    t.string   "name"
    t.string   "name_local"
    t.decimal  "lat",        precision: 18, scale: 12
    t.decimal  "lon",        precision: 18, scale: 12
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nearest_id"
    t.float    "x"
    t.float    "y"
    t.float    "tx"
    t.float    "ty"
    t.boolean  "transit"
    t.string   "color"
    t.float    "text_bias"
  end

  add_index "stations", ["city_id"], name: "index_stations_on_city_id"

end
