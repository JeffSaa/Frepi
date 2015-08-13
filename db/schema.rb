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

ActiveRecord::Schema.define(version: 18) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cities", force: :cascade do |t|
    t.integer  "state_id",   null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cities", ["state_id"], name: "index_cities_on_state_id"

  create_table "complaints", force: :cascade do |t|
    t.string   "message",    null: false
    t.string   "subject",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "complaints", ["user_id"], name: "index_complaints_on_user_id"

  create_table "countries", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.boolean  "active",        default: true, null: false
    t.integer  "status",        default: 0,    null: false
    t.date     "date",                         null: false
    t.datetime "delivery_time"
    t.integer  "sucursal_id",                  null: false
    t.integer  "user_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["sucursal_id"], name: "index_orders_on_sucursal_id"
  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "orders_products", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity",   default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "orders_products", ["order_id"], name: "index_orders_products_on_order_id"
  add_index "orders_products", ["product_id"], name: "index_orders_products_on_product_id"

  create_table "orders_schedules", force: :cascade do |t|
    t.integer  "order_id",    null: false
    t.integer  "schedule_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "orders_schedules", ["order_id"], name: "index_orders_schedules_on_order_id"
  add_index "orders_schedules", ["schedule_id"], name: "index_orders_schedules_on_schedule_id"

  create_table "products", force: :cascade do |t|
    t.string   "reference_code"
    t.string   "name",                          null: false
    t.decimal  "store_price",                   null: false
    t.decimal  "frepi_price",                   null: false
    t.string   "image",                         null: false
    t.boolean  "available",      default: true, null: false
    t.integer  "sales_count",    default: 0
    t.integer  "subcategory_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "products", ["subcategory_id"], name: "index_products_on_subcategory_id"

  create_table "schedules", force: :cascade do |t|
    t.integer  "day",        null: false
    t.time     "start_hour", null: false
    t.time     "end_hour",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shoppers", force: :cascade do |t|
    t.string   "name",                                                    null: false
    t.string   "last_name",                                               null: false
    t.string   "identification",                                          null: false
    t.string   "phone_number",                                            null: false
    t.integer  "status",                                                  null: false
    t.boolean  "active",                                   default: true, null: false
    t.string   "address"
    t.string   "company_email"
    t.string   "personal_email"
    t.string   "image_url"
    t.decimal  "latitude",       precision: 15, scale: 10
    t.decimal  "longitude",      precision: 15, scale: 10
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "shoppers_orders", force: :cascade do |t|
    t.integer  "shopper_id"
    t.integer  "order_id"
    t.datetime "accepted_date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "shoppers_orders", ["order_id"], name: "index_shoppers_orders_on_order_id"
  add_index "shoppers_orders", ["shopper_id"], name: "index_shoppers_orders_on_shopper_id"

  create_table "shoppers_schedules", force: :cascade do |t|
    t.integer  "shopper_id",  null: false
    t.integer  "schedule_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "shoppers_schedules", ["schedule_id"], name: "index_shoppers_schedules_on_schedule_id"
  add_index "shoppers_schedules", ["shopper_id"], name: "index_shoppers_schedules_on_shopper_id"

  create_table "states", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "states", ["country_id"], name: "index_states_on_country_id"

  create_table "store_partners", force: :cascade do |t|
    t.string   "nit",        null: false
    t.string   "store_name", null: false
    t.string   "logo",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subcategories", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id"

  create_table "sucursals", force: :cascade do |t|
    t.string   "name",                                           null: false
    t.string   "manager_full_name"
    t.string   "manager_email"
    t.string   "manager_phone_number"
    t.string   "phone_number"
    t.string   "address",                                        null: false
    t.decimal  "latitude",             precision: 15, scale: 10, null: false
    t.decimal  "longitude",            precision: 15, scale: 10, null: false
    t.integer  "store_partner_id",                               null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "sucursals", ["store_partner_id"], name: "index_sucursals_on_store_partner_id"

  create_table "sucursals_products", force: :cascade do |t|
    t.integer  "sucursal_id", null: false
    t.integer  "product_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sucursals_products", ["product_id"], name: "index_sucursals_products_on_product_id"
  add_index "sucursals_products", ["sucursal_id"], name: "index_sucursals_products_on_sucursal_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",                                                    null: false
    t.string   "last_name",                                               null: false
    t.string   "email",                                                   null: false
    t.string   "identification",                                          null: false
    t.string   "address",                                                 null: false
    t.string   "phone_number",                                            null: false
    t.integer  "user_type",                                default: 0,    null: false
    t.boolean  "active",                                   default: true, null: false
    t.string   "image"
    t.integer  "counter_orders",                           default: 0,    null: false
    t.decimal  "latitude",       precision: 15, scale: 10,                null: false
    t.decimal  "longitude",      precision: 15, scale: 10,                null: false
    t.integer  "city_id"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "users", ["city_id"], name: "index_users_on_city_id"

end
