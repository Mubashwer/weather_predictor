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

ActiveRecord::Schema.define(version: 20150516205816) do

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "station_id"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_update"
    t.string   "postcode"
  end

  create_table "observations", force: true do |t|
    t.string   "condition"
    t.integer  "unix_time"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "observations", ["location_id"], name: "index_observations_on_location_id"

  create_table "rainfalls", force: true do |t|
    t.float    "intensity"
    t.integer  "observation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unix_time"
  end

  add_index "rainfalls", ["observation_id"], name: "index_rainfalls_on_observation_id"

  create_table "temperatures", force: true do |t|
    t.float    "temp"
    t.integer  "observation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unix_time"
  end

  add_index "temperatures", ["observation_id"], name: "index_temperatures_on_observation_id"

  create_table "winds", force: true do |t|
    t.float    "speed"
    t.integer  "bearing"
    t.integer  "observation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unix_time"
  end

  add_index "winds", ["observation_id"], name: "index_winds_on_observation_id"

end
