# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_21_091800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "city_id", null: false
    t.string "title"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "landmark"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.bigint "product_sku_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["product_sku_id"], name: "index_cart_items_on_product_sku_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_cities_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "iso_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "order_details", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "payment_id"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_order_details_on_user_id"
  end

  create_table "order_histories", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "user_id"
    t.string "status", null: false
    t.text "note", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_order_histories_on_created_at"
    t.index ["order_id"], name: "index_order_histories_on_order_id"
    t.index ["status"], name: "index_order_histories_on_status"
    t.index ["user_id"], name: "index_order_histories_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "product_sku_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_sku_id"], name: "index_order_items_on_product_sku_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "total_price"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tracking_number"
    t.string "shipping_carrier"
    t.decimal "total_amount", precision: 10, scale: 2
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_details", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.decimal "amount"
    t.string "provider"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payment_details_on_order_id"
  end

  create_table "product_attributes", force: :cascade do |t|
    t.string "attribute_type"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_reviews", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.bigint "order_item_id"
    t.string "title", null: false
    t.text "content", null: false
    t.integer "rating", null: false
    t.boolean "approved", default: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_product_reviews_on_approved"
    t.index ["metadata"], name: "index_product_reviews_on_metadata", using: :gin
    t.index ["order_item_id"], name: "index_product_reviews_on_order_item_id"
    t.index ["product_id"], name: "index_product_reviews_on_product_id"
    t.index ["rating"], name: "index_product_reviews_on_rating"
    t.index ["user_id", "product_id"], name: "index_product_reviews_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_reviews_on_user_id"
  end

  create_table "product_skus", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "size_attribute_id", null: false
    t.bigint "color_attribute_id", null: false
    t.string "sku"
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_attribute_id"], name: "index_product_skus_on_color_attribute_id"
    t.index ["product_id"], name: "index_product_skus_on_product_id"
    t.index ["size_attribute_id"], name: "index_product_skus_on_size_attribute_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "sku", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock_quantity", default: 0, null: false
    t.jsonb "option_values", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
    t.index ["stock_quantity"], name: "index_product_variants_on_stock_quantity"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "summary"
    t.string "cover"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sub_category_id"
    t.boolean "active", default: true
    t.boolean "featured", default: false
    t.integer "stock_quantity", default: 0
    t.decimal "base_price", precision: 10, scale: 2, null: false
    t.decimal "average_rating", precision: 3, scale: 2
    t.integer "review_count", default: 0
    t.jsonb "metadata", default: {}
    t.index ["active"], name: "index_products_on_active"
    t.index ["average_rating"], name: "index_products_on_average_rating"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["metadata"], name: "index_products_on_metadata", using: :gin
    t.index ["sub_category_id"], name: "index_products_on_sub_category_id"
  end

  create_table "sub_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.date "birth_of_date"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_wishlists_on_product_id"
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "addresses", "cities"
  add_foreign_key "addresses", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_skus"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "cities", "countries"
  add_foreign_key "order_details", "users"
  add_foreign_key "order_histories", "orders"
  add_foreign_key "order_histories", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_skus"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_details", "orders"
  add_foreign_key "product_reviews", "order_items"
  add_foreign_key "product_reviews", "products"
  add_foreign_key "product_reviews", "users"
  add_foreign_key "product_skus", "product_attributes", column: "color_attribute_id"
  add_foreign_key "product_skus", "product_attributes", column: "size_attribute_id"
  add_foreign_key "product_skus", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "sub_categories"
  add_foreign_key "sub_categories", "categories"
  add_foreign_key "wishlists", "products"
  add_foreign_key "wishlists", "users"
end
