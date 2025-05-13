
I'll extend the database design to include comprehensive admin functionality. Here's the additional schema for the admin area:

```ruby
# Core User Management
create_table :users do |t|
  t.string :email, null: false, index: { unique: true }
  t.string :password_digest
  t.string :first_name
  t.string :last_name
  t.string :phone_number
  t.boolean :is_active, default: true
  t.datetime :last_login_at
  t.timestamps
end

rails g model User email:string password_digest:string first_name:string, last_name:string, phone_number:string, is_active:boolean, last_login_at:datetime

# User Authentication & Security
create_table :refresh_tokens do |t|
  t.references :user, null: false, foreign_key: true
  t.string :token, null: false, index: { unique: true }
  t.datetime :expires_at, null: false
  t.string :ip_address
  t.string :user_agent
  t.timestamps
end

# Address Management
create_table :addresses do |t|
  t.references :user, null: false, foreign_key: true
  t.string :address_type, null: false # shipping, billing
  t.string :street_address, null: false
  t.string :city, null: false
  t.string :state, null: false
  t.string :postal_code, null: false
  t.string :country, null: false
  t.boolean :is_default, default: false
  t.timestamps
end

rails generate model Address address_type:string street_address:string city:string state:string postal_code:string country:string is_default:boolean

# Product Catalog
create_table :categories do |t|
  t.string :name, null: false
  t.string :slug, null: false, index: { unique: true }
  t.text :description
  t.references :parent, foreign_key: { to_table: :categories }
  t.integer :position
  t.boolean :is_active, default: true
  t.timestamps
end

rails generate model Category name:string slug:string description:text parent:references position:integer is_active:boolean

create_table :products do |t|
  t.references :category, null: false, foreign_key: true
  t.string :name, null: false
  t.string :slug, null: false, index: { unique: true }
  t.text :description
  t.decimal :base_price, precision: 10, scale: 2, null: false
  t.integer :stock_quantity, default: 0
  t.boolean :is_active, default: true
  t.boolean :is_featured, default: false
  t.jsonb :metadata # for additional product attributes
  t.timestamps
end

rails generate model Product category:references name:string slug:string description:text base_price:decimal, stock_quantity:integer is_active:boolean is_featured:boolean metadata:jsonb

create_table :product_variants do |t|
  t.references :product, null: false, foreign_key: true
  t.string :sku, null: false, index: { unique: true }
  t.string :name
  t.decimal :price_adjustment, precision: 10, scale: 2, default: 0
  t.integer :stock_quantity, default: 0
  t.jsonb :attributes # color, size, etc.
  t.boolean :is_active, default: true
  t.timestamps
end

rails generate model ProductVariant product:references sku:string name:string price_adjustment:decimal stock_quantity:integer is_active:boolean

create_table :product_images do |t|
  t.references :product, null: false, foreign_key: true
  t.references :product_variant, foreign_key: true
  t.string :image_url, null: false
  t.integer :position
  t.boolean :is_primary, default: false
  t.timestamps
end

rails generate model ProductImage product:references product_variant:references image_url:string position:integer is_primary:boolean

# Inventory Management
create_table :inventory_transactions do |t|
  t.references :product_variant, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.string :transaction_type # purchase, sale, return, adjustment
  t.string :reference_type # order, return, adjustment
  t.bigint :reference_id
  t.text :notes
  t.timestamps
end

rails generate model InventoryTransaction product_variant:references quantity:integer transaction_type:string reference_type:string reference_id:bigint notes:text

# Shopping Cart
create_table :carts do |t|
  t.references :user, foreign_key: true
  t.string :session_id # for guest carts
  t.decimal :total_amount, precision: 10, scale: 2, default: 0
  t.timestamps
end

rails generate model Cart user:references session_id:string total_amount:decimal

create_table :cart_items do |t|
  t.references :cart, null: false, foreign_key: true
  t.references :product_variant, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.decimal :unit_price, precision: 10, scale: 2, null: false
  t.timestamps
end

rails generate model CartItem cart:references product_variant:references quantity:integer unit_price:decimal

# Order Management
create_table :orders do |t|
  t.references :user, null: false, foreign_key: true
  t.string :order_number, null: false, index: { unique: true }
  t.string :status, null: false # pending, processing, shipped, delivered, cancelled, refunded
  t.references :shipping_address, null: false, foreign_key: { to_table: :addresses }
  t.references :billing_address, null: false, foreign_key: { to_table: :addresses }
  t.decimal :subtotal, precision: 10, scale: 2, null: false
  t.decimal :shipping_cost, precision: 10, scale: 2, null: false
  t.decimal :tax_amount, precision: 10, scale: 2, null: false
  t.decimal :total_amount, precision: 10, scale: 2, null: false
  t.string :payment_method
  t.string :payment_status # pending, paid, failed, refunded
  t.string :tracking_number
  t.text :notes
  t.timestamps
end

rails generate model Order user:references order_number:string status:string shipping_address:references billing_address:references subtotal:decimal shipping_cost:decimal tax_amount:decimal total_amount:decimal payment_method:string payment_status:string tracking_number:string notes:text

create_table :order_items do |t|
  t.references :order, null: false, foreign_key: true
  t.references :product_variant, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.decimal :unit_price, precision: 10, scale: 2, null: false
  t.decimal :total_price, precision: 10, scale: 2, null: false
  t.timestamps
end

rails generate model OrderItem order:references product_variant:references quantity:integer unit_price:decimal total_price:decimal

# Reviews and Ratings
create_table :product_reviews do |t|
  t.references :user, null: false, foreign_key: true
  t.references :product, null: false, foreign_key: true
  t.references :order, foreign_key: true # to verify purchase
  t.string :title, null: false
  t.text :content
  t.integer :rating, null: false
  t.boolean :is_verified_purchase, default: false
  t.boolean :is_approved, default: false
  t.timestamps
end

# Promotions and Discounts
create_table :promotions do |t|
  t.string :code, null: false, index: { unique: true }
  t.string :name, null: false
  t.string :promotion_type # percentage, fixed_amount, free_shipping
  t.decimal :value, precision: 10, scale: 2
  t.datetime :start_date, null: false
  t.datetime :end_date
  t.integer :usage_limit
  t.integer :usage_count, default: 0
  t.boolean :is_active, default: true
  t.jsonb :conditions # minimum purchase, specific products, etc.
  t.timestamps
end

create_table :promotion_redemptions do |t|
  t.references :promotion, null: false, foreign_key: true
  t.references :order, foreign_key: true
  t.references :user, foreign_key: true
  t.decimal :discount_amount, precision: 10, scale: 2, null: false
  t.timestamps
end
```


```ruby
# Admin Management
create_table :admin_users do |t|
  t.string :email, null: false, index: { unique: true }
  t.string :password_digest
  t.string :first_name
  t.string :last_name
  t.string :phone_number
  t.boolean :is_super_admin, default: false
  t.boolean :is_active, default: true
  t.datetime :last_login_at
  t.string :last_login_ip
  t.timestamps
end

rails generate model AdminUser email:string password_digest:string first_name:string last_name:string phone_number:string is_super_admin:boolean is_active:boolean last_login_at:datetime last_login_ip:string

# Admin Roles and Permissions
create_table :admin_roles do |t|
  t.string :name, null: false, index: { unique: true }
  t.string :description
  t.jsonb :permissions # Store permissions as JSON
  t.boolean :is_active, default: true
  t.timestamps
end

rails generate model AdminRole name:string description:string permissions:jsonb is_active:boolean

create_table :admin_user_roles do |t|
  t.references :admin_user, null: false, foreign_key: true
  t.references :admin_role, null: false, foreign_key: true
  t.timestamps
  t.index [:admin_user_id, :admin_role_id], unique: true
end

rails generate model AdminUserRole admin_user:references admin_role:references

# Admin Activity Logging
create_table :admin_activity_logs do |t|
  t.references :admin_user, null: false, foreign_key: true
  t.string :action, null: false # create, update, delete, etc.
  t.string :resource_type, null: false # Product, Order, User, etc.
  t.bigint :resource_id, null: false
  t.jsonb :changes # Store before/after changes
  t.string :ip_address
  t.string :user_agent
  t.timestamps
  t.index [:resource_type, :resource_id]
end

rails generate model AdminActivityLog admin_user:references action:string resource_type:string resource_id:bigint changes:jsonb ip_address:string user_agent:string

# Admin Notifications
create_table :admin_notifications do |t|
  t.string :title, null: false
  t.text :message
  t.string :notification_type # order, inventory, review, etc.
  t.boolean :is_read, default: false
  t.jsonb :metadata # Additional notification data
  t.timestamps
end

create_table :admin_notification_reads do |t|
  t.references :admin_user, null: false, foreign_key: true
  t.references :admin_notification, null: false, foreign_key: true
  t.timestamps
  t.index [:admin_user_id, :admin_notification_id], unique: true
end

# Content Management
create_table :pages do |t|
  t.string :title, null: false
  t.string :slug, null: false, index: { unique: true }
  t.text :content
  t.string :meta_title
  t.text :meta_description
  t.boolean :is_published, default: false
  t.datetime :published_at
  t.references :admin_user, foreign_key: true
  t.timestamps
end

create_table :page_versions do |t|
  t.references :page, null: false, foreign_key: true
  t.text :content
  t.references :admin_user, foreign_key: true
  t.timestamps
end

# Marketing Tools
create_table :email_templates do |t|
  t.string :name, null: false
  t.string :subject, null: false
  t.text :content
  t.string :template_type # order_confirmation, shipping_notification, etc.
  t.boolean :is_active, default: true
  t.timestamps
end

create_table :newsletters do |t|
  t.string :subject, null: false
  t.text :content
  t.string :status # draft, scheduled, sent
  t.datetime :scheduled_at
  t.datetime :sent_at
  t.integer :recipients_count
  t.references :admin_user, foreign_key: true
  t.timestamps
end

# Reporting and Analytics
create_table :admin_dashboards do |t|
  t.string :name, null: false
  t.jsonb :widgets # Store dashboard widget configurations
  t.references :admin_user, foreign_key: true
  t.boolean :is_default, default: false
  t.timestamps
end

create_table :scheduled_reports do |t|
  t.string :name, null: false
  t.string :report_type # sales, inventory, customer, etc.
  t.jsonb :parameters # Report configuration
  t.string :frequency # daily, weekly, monthly
  t.string :format # pdf, csv, excel
  t.string :recipients # email addresses
  t.boolean :is_active, default: true
  t.datetime :last_generated_at
  t.timestamps
end

# System Settings
create_table :system_settings do |t|
  t.string :key, null: false, index: { unique: true }
  t.text :value
  t.string :value_type # string, integer, boolean, json
  t.string :category # general, payment, shipping, etc.
  t.text :description
  t.timestamps
end

# Import/Export Management
create_table :data_imports do |t|
  t.string :import_type # products, customers, orders, etc.
  t.string :status # pending, processing, completed, failed
  t.string :file_name
  t.integer :total_records
  t.integer :processed_records
  t.integer :successful_records
  t.integer :failed_records
  t.text :error_log
  t.references :admin_user, foreign_key: true
  t.timestamps
end

create_table :data_exports do |t|
  t.string :export_type # products, customers, orders, etc.
  t.string :status # pending, processing, completed, failed
  t.string :file_name
  t.integer :total_records
  t.references :admin_user, foreign_key: true
  t.timestamps
end

# Customer Support
create_table :support_tickets do |t|
  t.references :user, foreign_key: true
  t.string :ticket_number, null: false, index: { unique: true }
  t.string :subject, null: false
  t.text :description
  t.string :status # open, in_progress, resolved, closed
  t.string :priority # low, medium, high, urgent
  t.references :assigned_to, foreign_key: { to_table: :admin_users }
  t.timestamps
end

create_table :support_ticket_messages do |t|
  t.references :support_ticket, null: false, foreign_key: true
  t.references :sender, polymorphic: true # User or AdminUser
  t.text :message
  t.boolean :is_internal_note, default: false
  t.timestamps
end

create_table :support_ticket_attachments do |t|
  t.references :support_ticket_message, null: false, foreign_key: true
  t.string :file_name
  t.string :file_path
  t.string :file_type
  t.integer :file_size
  t.timestamps
end
```
