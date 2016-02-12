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

ActiveRecord::Schema.define(version: 20160212223300) do

  create_table "builds", force: :cascade do |t|
    t.string   "name",                limit: 255,                     null: false
    t.string   "build_id",            limit: 6,                       null: false
    t.string   "docker_container_id", limit: 64,                      null: false
    t.string   "ssh_server_address",  limit: 255,                     null: false
    t.integer  "ssh_server_port",     limit: 4,                       null: false
    t.string   "ssh_username",        limit: 255,                     null: false
    t.string   "ssh_password",        limit: 255,                     null: false
    t.string   "target_address",      limit: 255,                     null: false
    t.integer  "target_port",         limit: 4,                       null: false
    t.string   "exposed_bind",        limit: 255,                     null: false
    t.integer  "exposed_port",        limit: 4,                       null: false
    t.string   "operating_system",    limit: 10,  default: "windows", null: false
    t.string   "cpu_architecture",    limit: 10,  default: "amd64",   null: false
    t.string   "client_ip_address",   limit: 45,  default: "0.0.0.0", null: false
    t.boolean  "status",                                              null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "builds", ["build_id"], name: "index_builds_on_build_id", unique: true, using: :btree
  add_index "builds", ["client_ip_address"], name: "index_builds_on_client_ip_address", using: :btree
  add_index "builds", ["cpu_architecture"], name: "index_builds_on_cpu_architecture", using: :btree
  add_index "builds", ["docker_container_id"], name: "index_builds_on_docker_container_id", unique: true, using: :btree
  add_index "builds", ["operating_system"], name: "index_builds_on_operating_system", using: :btree

  create_table "connections", force: :cascade do |t|
    t.integer  "build_id",        limit: 4,                   null: false
    t.string   "remote",          limit: 255,                 null: false
    t.boolean  "is_connected",                default: false, null: false
    t.datetime "connected_at",                                null: false
    t.datetime "disconnected_at",                             null: false
  end

  add_index "connections", ["build_id"], name: "index_connections_on_build_id", using: :btree
  add_index "connections", ["is_connected"], name: "index_connections_on_is_connected", using: :btree

  add_foreign_key "connections", "builds"
end
