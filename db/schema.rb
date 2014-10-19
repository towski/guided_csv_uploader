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

ActiveRecord::Schema.define(version: 20141019044153) do

  create_table "dummy_employees", force: true do |t|
    t.integer  "shift_csv_id"
    t.string   "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dummy_employees", ["identifier"], name: "index_dummy_employees_on_identifier", unique: true

  create_table "dummy_shifts", force: true do |t|
    t.integer  "dummy_employee_id"
    t.integer  "clocked_in_time"
    t.datetime "clocked_in_at"
    t.integer  "clocked_out_time"
    t.datetime "clocked_out_at"
    t.integer  "wday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dummy_shifts", ["wday"], name: "index_dummy_shifts_on_wday"

  create_table "employee_dummies", force: true do |t|
    t.integer  "shift_csv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_csv_data_finders", force: true do |t|
    t.integer  "column_number"
    t.integer  "starting_row"
    t.string   "data_type"
    t.integer  "shift_csv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_csvs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
  end

  create_table "shift_dummies", force: true do |t|
    t.datetime "shift_start"
    t.datetime "shift_end"
    t.string   "day_of_week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
