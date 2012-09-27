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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120927171254) do

  create_table "app_settings", :force => true do |t|
    t.string   "code"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "employee_allocations", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "service_id"
    t.float    "allocation"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "employee_groups", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "group_id"
    t.boolean  "group_admin"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "employee_products", :force => true do |t|
    t.integer  "product_id"
    t.integer  "employee_id"
    t.float    "allocation"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "employees", :force => true do |t|
    t.string   "name_first"
    t.string   "name_last"
    t.string   "name_MI"
    t.string   "email"
    t.string   "osu_username"
    t.string   "osu_id"
    t.boolean  "site_admin"
    t.text     "notes"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "preferred_language"
    t.string   "preferred_theme"
    t.boolean  "new_user_reminder",  :default => true
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_groups", :force => true do |t|
    t.integer  "product_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_services", :force => true do |t|
    t.integer  "product_id"
    t.integer  "service_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "url"
    t.string   "product_state"
    t.string   "product_type"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
  end

end
