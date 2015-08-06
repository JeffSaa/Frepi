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

ActiveRecord::Schema.define(version: 8) do

  create_table "complaints", force: :cascade do |t|
    t.string   "message",    null: false
    t.string   "subject"
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "complaints", ["user_id"], name: "index_complaints_on_user_id"

  create_table "orders", force: :cascade do |t|
    t.boolean  "active",                    default: true, null: false
    t.integer  "status",                    default: 0,    null: false
    t.datetime "approximate_delivery_date"
    t.integer  "sucursal_id",                              null: false
    t.integer  "user_id",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["sucursal_id"], name: "index_orders_on_sucursal_id"
  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "orders_products", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "orders_products", ["order_id"], name: "index_orders_products_on_order_id"
  add_index "orders_products", ["product_id"], name: "index_orders_products_on_product_id"

  create_table "products", force: :cascade do |t|
    t.string   "reference_code"
    t.string   "name"
    t.decimal  "store_price"
    t.decimal  "frepi_price"
    t.string   "image"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "store_partners", force: :cascade do |t|
    t.string   "nit"
    t.string   "store_name"
    t.string   "manager_name"
    t.string   "manager_email"
    t.string   "manager_phone_number"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "sucursals", force: :cascade do |t|
    t.string   "name"
    t.string   "manager_full_name"
    t.string   "manager_email"
    t.string   "manager_phone_number"
    t.string   "phone_number"
    t.string   "address"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.integer  "store_partner_id",     null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "sucursals", ["store_partner_id"], name: "index_sucursals_on_store_partner_id"

  create_table "sucursals_products", force: :cascade do |t|
    t.integer  "sucursal_id"
    t.integer  "product_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sucursals_products", ["product_id"], name: "index_sucursals_products_on_product_id"
  add_index "sucursals_products", ["sucursal_id"], name: "index_sucursals_products_on_sucursal_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",                       null: false
    t.string   "last_name",                  null: false
    t.string   "email",                      null: false
    t.string   "identification",             null: false
    t.string   "address",                    null: false
    t.string   "phone_number",               null: false
    t.integer  "user_type",      default: 0
    t.string   "state"
    t.string   "country"
    t.string   "image"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
