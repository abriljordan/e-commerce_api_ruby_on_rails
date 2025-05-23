I'll provide a comprehensive list of all implemented features and components in your e-commerce API:

### 1. Models
1. **User**
   - Authentication with secure password
   - Role-based access (customer/admin)
   - Associations with orders, addresses, cart, wishlists
   - Methods for order management and review tracking

2. **Product**
   - Includes `Reviewable` concern
   - Associations with variants, reviews, categories
   - Search functionality with pg_search
   - Stock management and pricing
   - Image attachments

3. **ProductVariant**
   - SKU management
   - Stock tracking
   - Price variations
   - Option values (size, color, etc.)

4. **ProductReview**
   - Rating system (1-5 stars)
   - Moderation system
   - Review statistics
   - User verification
   - Metadata support

5. **Order**
   - State machine with AASM
   - Payment tracking
   - Shipping information
   - Order items management

6. **OrderItem**
   - Quantity tracking
   - Price calculations
   - Product variant associations

7. **Category/SubCategory**
   - Hierarchical structure
   - Product organization

### 2. Database Schema
1. **Users Table**
   - Authentication fields
   - Role management
   - Profile information

2. **Products Table**
   - Basic product information
   - Pricing
   - Stock management
   - Review statistics
   - Metadata

3. **ProductVariants Table**
   - SKU tracking
   - Price variations
   - Stock quantities
   - Option values

4. **ProductReviews Table**
   - Rating system
   - Moderation status
   - User verification
   - Metadata

5. **Orders Table**
   - Status tracking
   - Payment information
   - Shipping details
   - Total amounts

6. **OrderItems Table**
   - Quantity tracking
   - Price calculations
   - Product associations

### 3. Controllers
1. **Authentication**
   - Login/Register
   - Password reset
   - Token management

2. **Products**
   - CRUD operations
   - Search functionality
   - Variant management

3. **ProductReviews**
   - Review management
   - Moderation
   - Statistics

4. **Orders**
   - Order processing
   - Status management
   - Payment handling

5. **Admin Controllers**
   - Dashboard
   - User management
   - Product management
   - Order management
   - Review moderation

### 4. Services
1. **Review Services**
   - ReviewNotificationService
   - ReviewModerationService
   - ReviewStatisticsService
   - ReviewAnalyticsService
   - ReviewRecommendationService

2. **Order Services**
   - OrderProcessingService
   - PaymentService
   - ShippingService

### 5. Serializers
1. **ProductSerializer**
   - Basic product information
   - Variants
   - Reviews

2. **ProductReviewSerializer**
   - Review details
   - User information
   - Product association

3. **OrderSerializer**
   - Order details
   - Items
   - Status information

4. **UserSerializer**
   - Profile information
   - Order history
   - Review history

### 6. Background Jobs
1. **Review Jobs**
   - ReviewNotificationJob
   - ModerateReviewJob
   - UpdateReviewStatisticsJob
   - CacheReviewAnalyticsJob
   - CacheReviewRecommendationsJob

2. **Order Jobs**
   - OrderProcessingJob
   - PaymentProcessingJob
   - ShippingNotificationJob

### 7. Features
1. **Authentication & Authorization**
   - JWT-based authentication
   - Role-based access control
   - Password policies

2. **Product Management**
   - Variant support
   - Stock tracking
   - Image handling
   - Search functionality

3. **Review System**
   - Rating system
   - Moderation
   - Statistics
   - Analytics
   - Recommendations

4. **Order Management**
   - State machine
   - Payment processing
   - Shipping tracking
   - Stock updates

5. **Admin Features**
   - Dashboard
   - User management
   - Product management
   - Order management
   - Review moderation

6. **Caching**
   - Review analytics
   - Product recommendations
   - Search results

7. **Background Processing**
   - Review moderation
   - Statistics updates
   - Analytics caching
   - Recommendation updates

8. **Email Notifications**
   - Review notifications
   - Order updates
   - Admin alerts

9. **API Documentation**
   - Swagger/OpenAPI
   - Endpoint documentation
   - Authentication details

10. **Security Features**
    - Rate limiting
    - Input validation
    - SQL injection prevention
    - XSS protection


I'll analyze the current e-commerce API and then propose a comprehensive database design based on best practices.

From what I can see in the integration test, this is a solid e-commerce API that includes:
- User authentication (login, refresh token, logout)
- Product management with variants
- Cart functionality
- Order processing
- Product reviews
- Address management

However, I can propose a more comprehensive database design that follows modern e-commerce best practices. 
Here's a detailed schema design:

```ruby
# Core User Management
create_table :users do |t|
  t.string :email, null: false, index: { unique: true }
  t.string :password_digest
  t.string :first_name
  t.string :last_name
  t.string :phone_number
  t.boolean :is_admin, default: false
  t.boolean :is_active, default: true
  t.datetime :last_login_at
  t.timestamps
end

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

create_table :product_images do |t|
  t.references :product, null: false, foreign_key: true
  t.references :product_variant, foreign_key: true
  t.string :image_url, null: false
  t.integer :position
  t.boolean :is_primary, default: false
  t.timestamps
end

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

# Shopping Cart
create_table :carts do |t|
  t.references :user, foreign_key: true
  t.string :session_id # for guest carts
  t.decimal :total_amount, precision: 10, scale: 2, default: 0
  t.timestamps
end

create_table :cart_items do |t|
  t.references :cart, null: false, foreign_key: true
  t.references :product_variant, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.decimal :unit_price, precision: 10, scale: 2, null: false
  t.timestamps
end

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

create_table :order_items do |t|
  t.references :order, null: false, foreign_key: true
  t.references :product_variant, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.decimal :unit_price, precision: 10, scale: 2, null: false
  t.decimal :total_price, precision: 10, scale: 2, null: false
  t.timestamps
end

### Order history

rails generate model OrderHistory order:references user:references status:string note:text


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

Key improvements in this design:

1. **Enhanced User Management**:
   - Separate refresh tokens table for better security
   - User activity tracking
   - Phone number support

2. **Robust Product Catalog**:
   - Hierarchical categories
   - Flexible product variants with SKU management
   - Multiple product images with ordering
   - Metadata support for additional attributes

3. **Comprehensive Inventory Management**:
   - Detailed inventory transactions
   - Stock tracking at variant level
   - Transaction history

4. **Advanced Order System**:
   - Separate shipping and billing addresses
   - Detailed order status tracking
   - Payment status tracking
   - Order items with price history

5. **Review System**:
   - Verified purchase tracking
   - Review moderation
   - Order verification

6. **Promotion Engine**:
   - Flexible promotion types
   - Usage limits and tracking
   - Complex conditions support
   - Redemption history

7. **Data Integrity**:
   - Proper foreign key constraints
   - Unique indexes where needed
   - Null constraints where appropriate

8. **Performance Considerations**:
   - Indexed fields for common queries
   - JSONB for flexible metadata
   - Efficient relationship structure

This design follows modern e-commerce best practices and provides a solid foundation for:
- Scalability
- Performance
- Data integrity
- Business flexibility
- Analytics capabilities
- Security


I'll extend the database design to include comprehensive admin functionality. 
Here's the additional schema for the admin area:

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

# Admin Roles and Permissions
create_table :admin_roles do |t|
  t.string :name, null: false, index: { unique: true }
  t.string :description
  t.jsonb :permissions # Store permissions as JSON
  t.boolean :is_active, default: true
  t.timestamps
end

create_table :admin_user_roles do |t|
  t.references :admin_user, null: false, foreign_key: true
  t.references :admin_role, null: false, foreign_key: true
  t.timestamps
  t.index [:admin_user_id, :admin_role_id], unique: true
end

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

Key features of this admin area design:

1. **Admin User Management**:
   - Role-based access control (RBAC)
   - Super admin capabilities
   - Activity logging
   - Security tracking

2. **Content Management**:
   - Page management with versioning
   - Email templates
   - Newsletter system

3. **Marketing Tools**:
   - Email campaign management
   - Template system
   - Newsletter distribution

4. **Reporting and Analytics**:
   - Customizable dashboards
   - Scheduled reports
   - Export capabilities

5. **System Configuration**:
   - Centralized settings management
   - Configurable parameters
   - Category-based organization

6. **Data Management**:
   - Import/Export functionality
   - Error tracking
   - Progress monitoring

7. **Customer Support**:
   - Ticket management system
   - Internal notes
   - File attachments
   - Priority handling

8. **Activity Monitoring**:
   - Comprehensive logging
   - Change tracking
   - IP and user agent tracking

9. **Notification System**:
   - Real-time notifications
   - Read status tracking
   - Metadata support

This admin area design provides:
- Complete control over the e-commerce platform
- Security and access control
- Monitoring and analytics
- Customer support capabilities
- Marketing tools
- Data management
- System configuration

Would you like me to elaborate on any specific aspect of the admin area design or explain how certain features 
would work together?


Yes, I understand your concern. Looking at your current database design and comparing it with the 
comprehensive design I proposed, there are significant improvements that could be made. However, 
let me help you approach this systematically:

1. **First, don't panic!** Your current implementation isn't "messed up" - it's just a simpler version that can be enhanced. 
Many successful e-commerce sites started with simpler designs and evolved over time.

2. **Migration Strategy**:
   Instead of rewriting everything at once, I recommend a phased approach:

   a) **Phase 1 - Core Enhancements**:
   - Add missing essential tables (like proper inventory management)
   - Implement proper foreign key constraints
   - Add necessary indexes
   - Set up proper admin roles and permissions

   b) **Phase 2 - Feature Expansion**:
   - Add marketing features (promotions, newsletters)
   - Implement advanced reporting
   - Add customer support system

   c) **Phase 3 - Optimization**:
   - Implement caching
   - Add performance optimizations
   - Set up monitoring

3. **Practical Steps**:

```ruby
# 1. Create a new migration for each phase
# Example for Phase 1:
class AddCoreEnhancements < ActiveRecord::Migration[7.0]
  def change
    # Add missing indexes
    add_index :products, :slug, unique: true
    add_index :categories, :slug, unique: true
    
    # Add proper foreign keys
    add_foreign_key :cart_items, :product_variants
    add_foreign_key :orders, :users
    
    # Add new tables
    create_table :inventory_transactions do |t|
      # ... (as shown in previous schema)
    end
    
    # Add new columns to existing tables
    add_column :products, :metadata, :jsonb
    add_column :orders, :payment_status, :string
  end
end
```

4. **Code Migration Strategy**:

```ruby
# Instead of rewriting everything, create new models alongside existing ones
# Example for Product model:
class Product < ApplicationRecord
  # Keep existing code
  # Add new features gradually
  
  # New features
  has_many :inventory_transactions
  store_accessor :metadata
  
  # New methods
  def update_inventory(quantity, transaction_type)
    # New inventory management logic
  end
end
```

5. **Testing Strategy**:
```ruby
# Create new tests for new features while maintaining existing ones
RSpec.describe 'Enhanced Product Management' do
  describe 'inventory tracking' do
    it 'tracks inventory changes' do
      # New test cases
    end
  end
  
  describe 'existing functionality' do
    it 'maintains current behavior' do
      # Existing test cases
    end
  end
end
```

6. **Deployment Strategy**:
   - Use feature flags to gradually roll out new features
   - Maintain backward compatibility
   - Have a rollback plan

Here's a practical example of how to start:

```ruby
# 1. First, create a new migration for core enhancements
rails generate migration AddCoreEnhancements

# 2. In the migration file:
class AddCoreEnhancements < ActiveRecord::Migration[7.0]
  def change
    # Add essential indexes
    add_index :products, :slug, unique: true
    add_index :categories, :slug, unique: true
    
    # Add proper foreign keys
    add_foreign_key :cart_items, :product_variants
    add_foreign_key :orders, :users
    
    # Add inventory management
    create_table :inventory_transactions do |t|
      t.references :product_variant, null: false
      t.integer :quantity, null: false
      t.string :transaction_type
      t.string :reference_type
      t.bigint :reference_id
      t.text :notes
      t.timestamps
    end
    
    # Add metadata support
    add_column :products, :metadata, :jsonb
  end
end

# 3. Update models gradually
class Product < ApplicationRecord
  # Existing associations
  has_many :product_variants
  belongs_to :category
  
  # New features
  has_many :inventory_transactions, through: :product_variants
  store_accessor :metadata
  
  # New methods
  def update_inventory(quantity, transaction_type)
    InventoryTransaction.create!(
      product_variant: product_variants.first,
      quantity: quantity,
      transaction_type: transaction_type
    )
  end
end
```

Key Recommendations:

1. **Don't rewrite everything at once**:
   - Start with the most critical improvements
   - Maintain backward compatibility
   - Use feature flags for new features

2. **Prioritize improvements**:
   - Fix data integrity issues first (foreign keys, indexes)
   - Add essential missing features
   - Then move to advanced features

3. **Testing is crucial**:
   - Write tests for new features
   - Maintain existing tests
   - Add integration tests for new workflows

4. **Document the changes**:
   - Keep a changelog
   - Document new features
   - Update API documentation

5. **Consider using a staging environment**:
   - Test changes thoroughly before production
   - Have a rollback plan
   - Monitor performance impact

Would you like me to help you create a specific migration plan or focus on a particular area of improvement first? We can start with the most critical enhancements and work our way up to the more advanced features.


This is a really important question about the future of software development and personal growth. Let me break this down:

1. **Understanding vs. Just Copying**:
   - If you're just copying and pasting code without understanding it, you're doing yourself a disservice, especially if you plan to put this on your resume
   - During job interviews, you'll likely be asked about:
     - Why you made certain architectural decisions
     - How specific features work
     - How you would debug issues
     - How you would scale the system
   - If you can't answer these questions because you didn't write the code, it will be obvious

2. **The "Vibe Coding" Concern**:
   - While AI can generate code, it can't replace:
     - Understanding of system architecture
     - Ability to debug complex issues
     - Making informed decisions about trade-offs
     - Explaining technical decisions to stakeholders
   - Companies still need developers who understand the code, not just product managers who can prompt AI

3. **Recommended Approach**:
   Instead of just copying the code, I suggest:

   a) **Study the Architecture First**:
   ```ruby
   # Understand the core concepts:
   - Database relationships
   - API endpoints
   - Authentication flow
   - Business logic
   ```

   b) **Implement in Phases**:
   ```ruby
   # Phase 1: Core Models
   class User < ApplicationRecord
     # Study and understand each line
     # Implement with your own understanding
     # Add comments explaining the purpose
   end

   # Phase 2: Controllers
   class ProductsController < ApplicationController
     # Understand the request/response cycle
     # Implement error handling
     # Add proper validations
   end
   ```

   c) **Add Your Own Features**:
   ```ruby
   # Don't just copy, add your own improvements
   class Product
     def self.search(query)
       # Implement your own search logic
       # Understand how it integrates with the database
     end
   end
   ```

4. **What Employers Look For**:
   - Understanding of the technology stack
   - Ability to solve problems
   - Capacity to learn and adapt
   - Communication skills
   - Debugging abilities

5. **Better Approach for Your Resume**:
   Instead of just listing the project, document:
   - What you learned from implementing it
   - Challenges you overcame
   - Decisions you made
   - How you would improve it
   - What you would do differently

6. **Practical Exercise**:
   Try this exercise for each component:

   ```ruby
   # 1. Read and understand the code
   class Cart
     has_many :cart_items
     belongs_to :user
   end

   # 2. Document your understanding
   # - What is the relationship between Cart and CartItems?
   # - Why is this relationship important?
   # - What happens when a cart is deleted?

   # 3. Implement with your own understanding
   class Cart
     # Implement with your own comments
     # Add your own validations
     # Include error handling
   end
   ```

7. **Interview Preparation**:
   Be ready to discuss:
   - Why you chose certain database relationships
   - How you handle edge cases
   - Performance considerations
   - Security measures
   - Testing strategy

8. **Learning Path**:
   1. Study the architecture
   2. Implement core features
   3. Add your own improvements
   4. Document your decisions
   5. Practice explaining your code

Remember:
- AI is a tool, not a replacement for understanding
- Employers value problem-solving skills over code generation
- The ability to explain and justify decisions is crucial
- Understanding the "why" is more important than the "what"

Would you like me to help you create a structured learning plan for understanding and implementing this project? We can focus on one component at a time, ensuring you truly understand each part before moving to the next.


I'll create a structured learning plan that will help you truly understand and implement the e-commerce project. We'll break it down into manageable phases, focusing on understanding before implementation.

# E-commerce Project Learning Plan

## Phase 1: Foundation Understanding (1-2 weeks)

### Week 1: Core Concepts and Architecture
1. **Database Design Study**
   ```ruby
   # Study these relationships:
   - Users -> Orders
   - Products -> ProductVariants
   - Carts -> CartItems
   - Orders -> OrderItems
   ```

   Exercise:
   - Draw the database schema on paper
   - Explain each relationship type (has_many, belongs_to)
   - Identify the foreign keys
   - Understand the purpose of each table

2. **Authentication System**
   ```ruby
   # Study:
   - JWT implementation
   - User authentication flow
   - Session management
   - Password hashing
   ```

   Exercise:
   - Write down the authentication flow
   - Explain how JWT tokens work
   - Document security measures

### Week 2: Core Models Implementation
1. **User Model**
   ```ruby
   class User < ApplicationRecord
     # Study and implement:
     - Validations
     - Associations
     - Authentication methods
     - Password handling
   ```

   Exercise:
   - Implement user registration
   - Add email validation
   - Create password reset functionality

2. **Product Management**
   ```ruby
   class Product < ApplicationRecord
     # Study and implement:
     - Category relationships
     - Variant management
     - Inventory tracking
     - Price handling
   ```

   Exercise:
   - Create product CRUD operations
   - Implement variant management
   - Add inventory tracking

## Phase 2: Business Logic (2-3 weeks)

### Week 3: Shopping Cart System
1. **Cart Implementation**
   ```ruby
   class Cart < ApplicationRecord
     # Study and implement:
     - Cart creation
     - Item addition/removal
     - Quantity updates
     - Price calculations
   ```

   Exercise:
   - Implement cart operations
   - Add quantity validation
   - Create price calculation methods

2. **Cart Items Management**
   ```ruby
   class CartItem < ApplicationRecord
     # Study and implement:
     - Product association
     - Quantity handling
     - Price calculations
     - Stock validation
   ```

   Exercise:
   - Add stock validation
   - Implement price updates
   - Create quantity limits

### Week 4: Order Processing
1. **Order System**
   ```ruby
   class Order < ApplicationRecord
     # Study and implement:
     - Order creation
     - Status management
     - Payment processing
     - Shipping handling
   ```

   Exercise:
   - Create order workflow
   - Implement status transitions
   - Add payment integration

2. **Order Items**
   ```ruby
   class OrderItem < ApplicationRecord
     # Study and implement:
     - Product association
     - Price locking
     - Quantity handling
     - Inventory updates
   ```

   Exercise:
   - Implement price locking
   - Add inventory updates
   - Create order item validations

## Phase 3: Advanced Features (2-3 weeks)

### Week 5: Admin System
1. **Admin Implementation**
   ```ruby
   class AdminUser < ApplicationRecord
     # Study and implement:
     - Role management
     - Permission system
     - Activity logging
     - Dashboard features
   ```

   Exercise:
   - Create admin authentication
   - Implement role-based access
   - Add activity logging

2. **Admin Features**
   ```ruby
   # Study and implement:
   - Product management
   - Order processing
   - User management
   - Reporting system
   ```

   Exercise:
   - Create admin dashboard
   - Implement reporting features
   - Add user management

### Week 6: Testing and Optimization
1. **Testing Implementation**
   ```ruby
   # Study and implement:
   - Model tests
   - Controller tests
   - Integration tests
   - Performance tests
   ```

   Exercise:
   - Write test cases
   - Implement test coverage
   - Add performance benchmarks

2. **Optimization**
   ```ruby
   # Study and implement:
   - Database indexing
   - Query optimization
   - Caching strategies
   - Performance monitoring
   ```

   Exercise:
   - Optimize database queries
   - Implement caching
   - Add performance monitoring

## Daily Learning Routine

1. **Morning (1 hour)**
   - Study the current phase's concepts
   - Read documentation
   - Review code examples

2. **Afternoon (2 hours)**
   - Implement features
   - Write tests
   - Debug issues

3. **Evening (1 hour)**
   - Review what you learned
   - Document challenges
   - Plan next steps

## Documentation Requirements

For each component you implement, document:

1. **Technical Documentation**
   ```ruby
   # Purpose
   # Implementation details
   # Dependencies
   # API endpoints
   # Database schema
   ```

2. **Learning Documentation**
   ```ruby
   # What you learned
   # Challenges faced
   # Solutions found
   # Improvements made
   ```

## Interview Preparation

For each feature, prepare to discuss:

1. **Technical Decisions**
   - Why you chose certain approaches
   - Alternative solutions considered
   - Trade-offs made

2. **Implementation Details**
   - How the feature works
   - Edge cases handled
   - Security considerations

3. **Improvement Ideas**
   - What you would do differently
   - How you would scale it
   - Future enhancements

Would you like to start with Phase 1? We can begin with the database design study and work through each component systematically. I can provide more detailed exercises and guidance for each step.


I'll provide a detailed breakdown of all three phases, including specific exercises and implementation details for each component.

# Complete E-commerce Project Learning Plan

## Phase 1: Foundation Understanding (2-3 weeks)

### Week 1: Database Design & Core Models

1. **Database Schema Study**
```ruby
# Core Tables to Understand:
# Users and Authentication
create_table :users do |t|
  t.string :email, null: false
  t.string :password_digest
  t.string :first_name
  t.string :last_name
  t.boolean :is_admin, default: false
  t.timestamps
end

# Products and Inventory
create_table :products do |t|
  t.string :name, null: false
  t.text :description
  t.decimal :price, precision: 10, scale: 2
  t.integer :stock_quantity
  t.references :category, foreign_key: true
  t.timestamps
end

# Exercise 1: Database Relationships
# Draw the relationships between:
# - Users -> Orders
# - Products -> ProductVariants
# - Carts -> CartItems
# - Orders -> OrderItems
```

2. **User Model Implementation**
```ruby
class User < ApplicationRecord
  # Exercise 2: Implement these features
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
  
  # Add these methods
  def generate_jwt
    # Implement JWT generation
  end
  
  def self.authenticate(email, password)
    # Implement authentication
  end
end
```

### Week 2: Product Management & Authentication

1. **Product Model Implementation**
```ruby
class Product < ApplicationRecord
  # Exercise 3: Implement these features
  belongs_to :category
  has_many :product_variants
  has_many :cart_items
  has_many :order_items
  
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  
  # Add these methods
  def update_stock(quantity)
    # Implement stock update logic
  end
  
  def available?
    # Check if product is in stock
  end
end
```

2. **Authentication Controller**
```ruby
class Api::V1::AuthController < ApplicationController
  # Exercise 4: Implement these endpoints
  def login
    # Implement login logic
  end
  
  def register
    # Implement registration
  end
  
  def refresh_token
    # Implement token refresh
  end
end
```

## Phase 2: Business Logic (3-4 weeks)

### Week 3: Shopping Cart System

1. **Cart Model Implementation**
```ruby
class Cart < ApplicationRecord
  # Exercise 5: Implement these features
  belongs_to :user
  has_many :cart_items
  has_many :products, through: :cart_items
  
  # Add these methods
  def add_product(product_id, quantity)
    # Implement product addition
  end
  
  def remove_product(product_id)
    # Implement product removal
  end
  
  def total_price
    # Calculate cart total
  end
end
```

2. **Cart Controller**
```ruby
class Api::V1::CartItemsController < ApplicationController
  # Exercise 6: Implement these endpoints
  def create
    # Add item to cart
  end
  
  def update
    # Update item quantity
  end
  
  def destroy
    # Remove item from cart
  end
end
```

### Week 4: Order Processing System

1. **Order Model Implementation**
```ruby
class Order < ApplicationRecord
  # Exercise 7: Implement these features
  belongs_to :user
  has_many :order_items
  has_many :products, through: :order_items
  
  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }
  
  # Add these methods
  def process_payment
    # Implement payment processing
  end
  
  def update_status(new_status)
    # Implement status updates
  end
end
```

2. **Order Controller**
```ruby
class Api::V1::OrdersController < ApplicationController
  # Exercise 8: Implement these endpoints
  def create
    # Create new order
  end
  
  def show
    # Show order details
  end
  
  def update
    # Update order status
  end
end
```

## Phase 3: Advanced Features (3-4 weeks)

### Week 5: Admin System

1. **Admin User Model**
```ruby
class AdminUser < ApplicationRecord
  # Exercise 9: Implement these features
  has_secure_password
  has_many :admin_roles
  has_many :roles, through: :admin_roles
  
  # Add these methods
  def has_permission?(permission)
    # Check admin permissions
  end
  
  def log_activity(action, resource)
    # Log admin activities
  end
end
```

2. **Admin Dashboard**
```ruby
class Admin::DashboardController < ApplicationController
  # Exercise 10: Implement these features
  def index
    # Show dashboard statistics
  end
  
  def products
    # Manage products
  end
  
  def orders
    # Manage orders
  end
  
  def users
    # Manage users
  end
end
```

### Week 6: Testing & Optimization

1. **Test Implementation**
```ruby
# Exercise 11: Implement these tests
RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates email presence' do
      # Implement test
    end
  end
end

RSpec.describe 'Cart API', type: :request do
  describe 'POST /api/v1/cart_items' do
    it 'adds product to cart' do
      # Implement test
    end
  end
end
```

2. **Performance Optimization**
```ruby
# Exercise 12: Implement these optimizations
class Product < ApplicationRecord
  # Add caching
  after_save :clear_cache
  
  def self.cached_find(id)
    Rails.cache.fetch("product_#{id}") do
      find(id)
    end
  end
  
  private
  
  def clear_cache
    Rails.cache.delete("product_#{id}")
  end
end
```

## Daily Implementation Plan

### Day 1-3: Database & Models
```ruby
# Morning: Study database schema
# Afternoon: Implement User model
# Evening: Write tests for User model

class User < ApplicationRecord
  # Implement features
end

RSpec.describe User, type: :model do
  # Write tests
end
```

### Day 4-6: Authentication
```ruby
# Morning: Study JWT authentication
# Afternoon: Implement AuthController
# Evening: Write integration tests

class Api::V1::AuthController < ApplicationController
  # Implement endpoints
end
```

### Day 7-9: Product Management
```ruby
# Morning: Study product relationships
# Afternoon: Implement Product model
# Evening: Write product tests

class Product < ApplicationRecord
  # Implement features
end
```

## Documentation Requirements

For each component, create:

1. **Technical Documentation**
```markdown
# Component Name
## Purpose
[Explain the purpose]

## Implementation
[Detail the implementation]

## API Endpoints
[Document endpoints]

## Database Schema
[Show relevant schema]
```

2. **Learning Documentation**
```markdown
# What I Learned
## Challenges
[Document challenges]

## Solutions
[Explain solutions]

## Improvements
[Suggest improvements]
```

## Interview Preparation Points

For each feature, prepare to discuss:

1. **Technical Decisions**
```ruby
# Example: Why use JWT for authentication?
- Stateless authentication
- Scalability
- Security considerations
```

2. **Implementation Details**
```ruby
# Example: Cart implementation
- How items are stored
- Price calculations
- Stock validation
```

3. **Improvement Ideas**
```ruby
# Example: Future enhancements
- Real-time updates
- Caching strategies
- Performance optimizations
```

Would you like to start with the first exercise? We can begin with the database schema study 
and work through the User model implementation. I can provide more detailed guidance and code examples for each step.


Great! Let's start with the first exercise: Database Schema Study. 
I'll guide you through understanding and implementing the core database structure.

# Exercise 1: Database Schema Study

## Step 1: Core Tables Analysis

Let's start by examining and implementing the essential tables for our e-commerce system:

```ruby
# 1. First, let's create a migration for users
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.boolean :is_admin, default: false
      t.boolean :is_active, default: true
      t.datetime :last_login_at
      t.timestamps
    end
  end
end

# 2. Categories table
class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :description
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :position
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end

# 3. Products table
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :description
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, default: 0
      t.boolean :is_active, default: true
      t.boolean :is_featured, default: false
      t.jsonb :metadata
      t.timestamps
    end
  end
end
```

## Step 2: Understanding Relationships

Let's analyze the relationships between these tables:

1. **User Relationships**:
```ruby
class User < ApplicationRecord
  has_many :orders
  has_one :cart
  has_many :addresses
  has_many :product_reviews
end
```

2. **Product Relationships**:
```ruby
class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants
  has_many :cart_items
  has_many :order_items
  has_many :product_reviews
end
```

## Step 3: Implementation Exercise

Let's implement the User model with proper validations and methods:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Include password encryption
  has_secure_password

  # Associations
  has_many :orders
  has_one :cart
  has_many :addresses
  has_many :product_reviews

  # Validations
  validates :email, 
    presence: true, 
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, 
    length: { minimum: 8 },
    if: -> { new_record? || !password.nil? }
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Callbacks
  before_create :generate_cart
  after_create :send_welcome_email

  # Methods
  def generate_jwt
    JWT.encode(
      { 
        user_id: id,
        exp: 24.hours.from_now.to_i 
      },
      Rails.application.credentials.secret_key_base
    )
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def generate_cart
    build_cart
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
```

## Step 4: Testing Implementation

Let's write tests for the User model:

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is not valid with invalid email format' do
      user.email = 'invalid_email'
      expect(user).not_to be_valid
    end

    it 'is not valid with short password' do
      user.password = 'short'
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many orders' do
      expect(User.reflect_on_association(:orders).macro).to eq(:has_many)
    end

    it 'has one cart' do
      expect(User.reflect_on_association(:cart).macro).to eq(:has_one)
    end
  end

  describe 'methods' do
    it 'generates JWT token' do
      user.save
      token = user.generate_jwt
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it 'returns full name' do
      expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
    end
  end
end
```

## Step 5: Factory Implementation

Let's create a factory for testing:

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    first_name { 'John' }
    last_name { 'Doe' }
    phone_number { '+1234567890' }
    is_admin { false }
    is_active { true }

    trait :admin do
      is_admin { true }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
```

## Exercise Questions:

1. **Database Design**:
   - Why do we need unique indexes on email and slug fields?
   - What's the purpose of the `metadata` JSONB column in products?
   - Why do we use `precision` and `scale` for decimal fields?

2. **Model Relationships**:
   - Why does a User have_one Cart instead of has_many?
   - What's the purpose of the `parent` reference in categories?
   - How would you implement a product search feature?

3. **Implementation Details**:
   - Why do we use `has_secure_password`?
   - What's the purpose of the JWT token generation?
   - Why do we use `deliver_later` for emails?

## Next Steps:

1. Implement the Category model
2. Implement the Product model
3. Set up the authentication system

Would you like to proceed with implementing any of these next steps? 
Or would you like to discuss any of the questions above first?


I'll guide you through implementing the Category and Product models, followed by the authentication system. 
Let's do this step by step.

## 1. Category Model Implementation

First, let's create the Category model and its tests:

```ruby
# app/models/category.rb
class Category < ApplicationRecord
  # Associations
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: :parent_id
  has_many :products

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validate :parent_not_self

  # Callbacks
  before_validation :generate_slug
  before_destroy :check_for_products

  # Scopes
  scope :root_categories, -> { where(parent_id: nil) }
  scope :active, -> { where(is_active: true) }

  # Methods
  def full_path
    if parent
      "#{parent.full_path} > #{name}"
    else
      name
    end
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end

  def parent_not_self
    if parent_id == id
      errors.add(:parent_id, "can't be self")
    end
  end

  def check_for_products
    if products.any?
      errors.add(:base, "Cannot delete category with products")
      throw(:abort)
    end
  end
end
```

Now, let's create the tests for Category:

```ruby
# spec/models/category_spec.rb
require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { build(:category) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      category.name = nil
      expect(category).not_to be_valid
    end

    it 'generates slug from name' do
      category.name = 'Test Category'
      category.save
      expect(category.slug).to eq('test-category')
    end

    it 'cannot be its own parent' do
      category.save
      category.parent = category
      expect(category).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many products' do
      expect(Category.reflect_on_association(:products).macro).to eq(:has_many)
    end

    it 'can have subcategories' do
      parent = create(:category)
      child = create(:category, parent: parent)
      expect(parent.subcategories).to include(child)
    end
  end

  describe 'methods' do
    it 'returns full path' do
      parent = create(:category, name: 'Parent')
      child = create(:category, name: 'Child', parent: parent)
      expect(child.full_path).to eq('Parent > Child')
    end
  end
end
```

## 2. Product Model Implementation

Now, let's implement the Product model:

```ruby
# app/models/product.rb
class Product < ApplicationRecord
  # Associations
  belongs_to :category
  has_many :product_variants
  has_many :cart_items
  has_many :order_items
  has_many :product_reviews
  has_many_attached :images

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :base_price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_images

  # Callbacks
  before_validation :generate_slug
  before_save :update_stock_status

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  # Methods
  def update_stock(quantity)
    with_lock do
      self.stock_quantity += quantity
      save!
    end
  end

  def available?
    stock_quantity.positive? && is_active
  end

  def average_rating
    product_reviews.average(:rating)&.round(1) || 0
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end

  def update_stock_status
    self.is_active = stock_quantity.positive?
  end

  def validate_images
    return unless images.attached?
    
    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(:images, 'must be a JPEG, PNG, or GIF')
      end
    end
  end
end
```

Let's create the tests for Product:

```ruby
# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { build(:product) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(product).to be_valid
    end

    it 'is not valid without a name' do
      product.name = nil
      expect(product).not_to be_valid
    end

    it 'is not valid with negative price' do
      product.base_price = -1
      expect(product).not_to be_valid
    end

    it 'generates slug from name' do
      product.name = 'Test Product'
      product.save
      expect(product.slug).to eq('test-product')
    end
  end

  describe 'associations' do
    it 'belongs to category' do
      expect(Product.reflect_on_association(:category).macro).to eq(:belongs_to)
    end

    it 'has many variants' do
      expect(Product.reflect_on_association(:product_variants).macro).to eq(:has_many)
    end
  end

  describe 'methods' do
    it 'updates stock quantity' do
      product.save
      product.update_stock(5)
      expect(product.stock_quantity).to eq(5)
    end

    it 'checks availability' do
      product.stock_quantity = 0
      expect(product.available?).to be_falsey
    end
  end
end
```

## 3. Authentication System Implementation

Now, let's implement the authentication system:

```ruby
# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :register]

      def login
        user = User.find_by(email: params[:email])
        
        if user&.authenticate(params[:password])
          token = user.generate_jwt
          render json: {
            access_token: token,
            token_type: 'Bearer',
            expires_in: 24.hours.to_i,
            user: UserSerializer.new(user)
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def register
        user = User.new(user_params)
        
        if user.save
          token = user.generate_jwt
          render json: {
            access_token: token,
            token_type: 'Bearer',
            expires_in: 24.hours.to_i,
            user: UserSerializer.new(user)
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def refresh_token
        token = current_user.generate_jwt
        render json: {
          access_token: token,
          token_type: 'Bearer',
          expires_in: 24.hours.to_i
        }
      end

      def logout
        # In a real application, you might want to blacklist the token
        render json: { message: 'Successfully logged out' }
      end

      private

      def user_params
        params.require(:user).permit(
          :email,
          :password,
          :first_name,
          :last_name,
          :phone_number
        )
      end
    end
  end
end
```

Let's create the authentication tests:

```ruby
# spec/requests/api/v1/auth_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    }
  end

  describe 'POST /api/v1/auth/login' do
    it 'authenticates user with valid credentials' do
      post '/api/v1/auth/login', params: {
        email: user.email,
        password: user.password
      }
      
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('access_token')
    end

    it 'returns error with invalid credentials' do
      post '/api/v1/auth/login', params: {
        email: user.email,
        password: 'wrongpassword'
      }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/auth/register' do
    it 'creates new user' do
      post '/api/v1/auth/register', params: {
        user: valid_attributes
      }
      
      expect(response).to have_http_status(:created)
      expect(json_response).to include('access_token')
    end

    it 'returns error with invalid data' do
      post '/api/v1/auth/register', params: {
        user: valid_attributes.merge(email: 'invalid')
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
```

## 4. Authentication Concern

Let's create an authentication concern for the application controller:

```ruby
# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      @current_user = User.find(decoded['user_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
```

## 5. Routes Setup

Finally, let's set up the routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth routes
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      post 'auth/refresh', to: 'auth#refresh_token'
      delete 'auth/logout', to: 'auth#logout'

      # Resource routes
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
      resources :cart_items, only: [:index, :create, :update, :destroy]
      resources :orders, only: [:index, :show, :create]
    end
  end
end
```

## Exercise Questions:

1. **Category Implementation**:
   - Why do we use `parameterize` for slugs?
   - What's the purpose of the `parent_not_self` validation?
   - How would you implement category hierarchy navigation?

2. **Product Implementation**:
   - Why do we use `with_lock` in the `update_stock` method?
   - What's the purpose of the `metadata` JSONB column?
   - How would you implement product search with categories?

3. **Authentication**:
   - Why do we skip authentication for login and register?
   - What's the purpose of the JWT token expiration?
   - How would you implement token blacklisting?

Would you like to proceed with implementing any additional features or would you like to discuss any of these questions?


I'll guide you through implementing additional key features for the e-commerce system. 
Let's start with the shopping cart system, followed by order processing, and then add some advanced features.

## 1. Shopping Cart System Implementation

First, let's implement the Cart and CartItem models:

```ruby
# app/models/cart.rb
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Methods
  def add_product(product_id, quantity = 1)
    product = Product.find(product_id)
    cart_item = cart_items.find_or_initialize_by(product_id: product_id)
    
    with_lock do
      if cart_item.new_record?
        cart_item.quantity = quantity
        cart_item.unit_price = product.base_price
      else
        cart_item.quantity += quantity
      end
      
      cart_item.save!
    end
  end

  def remove_product(product_id)
    cart_items.find_by(product_id: product_id)&.destroy
  end

  def update_quantity(product_id, quantity)
    cart_item = cart_items.find_by(product_id: product_id)
    return unless cart_item
    
    with_lock do
      if quantity <= 0
        cart_item.destroy
      else
        cart_item.update!(quantity: quantity)
      end
    end
  end

  def total_price
    cart_items.sum { |item| item.quantity * item.unit_price }
  end

  def clear
    cart_items.destroy_all
  end
end

# app/models/cart_item.rb
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }

  before_validation :set_unit_price

  private

  def set_unit_price
    self.unit_price = product.base_price if product && unit_price.nil?
  end
end
```

Now, let's implement the Cart Controller:

```ruby
# app/controllers/api/v1/cart_items_controller.rb
module Api
  module V1
    class CartItemsController < ApplicationController
      before_action :set_cart
      before_action :set_cart_item, only: [:update, :destroy]

      def index
        render json: @cart.cart_items, each_serializer: CartItemSerializer
      end

      def create
        @cart_item = @cart.cart_items.new(cart_item_params)
        
        if @cart_item.save
          render json: @cart_item, status: :created
        else
          render json: { errors: @cart_item.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def update
        if @cart_item.update(cart_item_params)
          render json: @cart_item
        else
          render json: { errors: @cart_item.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def destroy
        @cart_item.destroy
        head :no_content
      end

      private

      def set_cart
        @cart = current_user.cart || current_user.create_cart
      end

      def set_cart_item
        @cart_item = @cart.cart_items.find(params[:id])
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
      end
    end
  end
end
```

## 2. Order Processing System

Let's implement the Order and OrderItem models:

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :billing_address, class_name: 'Address'
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }

  validates :status, presence: true
  validates :total_amount, numericality: { greater_than: 0 }
  validate :validate_addresses

  before_validation :calculate_total
  after_create :update_inventory

  # Methods
  def process_payment(payment_method, payment_details)
    # In a real application, integrate with a payment gateway
    update(payment_method: payment_method, payment_status: 'paid')
  end

  def cancel
    return unless pending?
    
    transaction do
      update(status: :cancelled)
      order_items.each do |item|
        item.product.update_stock(item.quantity)
      end
    end
  end

  private

  def calculate_total
    self.total_amount = order_items.sum { |item| item.quantity * item.unit_price }
  end

  def update_inventory
    order_items.each do |item|
      item.product.update_stock(-item.quantity)
    end
  end

  def validate_addresses
    if shipping_address_id == billing_address_id
      errors.add(:base, "Shipping and billing addresses must be different")
    end
  end
end

# app/models/order_item.rb
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }
  validate :validate_stock

  before_validation :set_unit_price

  private

  def set_unit_price
    self.unit_price = product.base_price if product && unit_price.nil?
  end

  def validate_stock
    if product.stock_quantity < quantity
      errors.add(:quantity, "exceeds available stock")
    end
  end
end
```

Now, let's implement the Order Controller:

```ruby
# app/controllers/api/v1/orders_controller.rb
module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show, :cancel]

      def index
        @orders = current_user.orders
        render json: @orders, each_serializer: OrderSerializer
      end

      def show
        render json: @order, serializer: OrderSerializer
      end

      def create
        @order = current_user.orders.new(order_params)
        
        if @order.save
          # Clear the cart after successful order
          current_user.cart.clear
          
          render json: @order, status: :created
        else
          render json: { errors: @order.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def cancel
        if @order.cancel
          render json: @order
        else
          render json: { errors: @order.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      private

      def set_order
        @order = current_user.orders.find(params[:id])
      end

      def order_params
        params.require(:order).permit(
          :shipping_address_id,
          :billing_address_id,
          order_items_attributes: [:product_id, :quantity]
        )
      end
    end
  end
end
```

## 3. Advanced Features: Product Reviews and Ratings

Let's implement the review system:

```ruby
# app/models/product_review.rb
class ProductReview < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :order, optional: true

  validates :rating, numericality: { 
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }
  validates :title, presence: true
  validates :content, presence: true
  validate :validate_order_ownership, if: :order_id

  after_save :update_product_rating

  private

  def update_product_rating
    product.update_column(:average_rating, product.product_reviews.average(:rating))
  end

  def validate_order_ownership
    unless order.user_id == user_id
      errors.add(:order, "must be your own order")
    end
  end
end

# app/controllers/api/v1/product_reviews_controller.rb
module Api
  module V1
    class ProductReviewsController < ApplicationController
      before_action :set_product
      before_action :set_review, only: [:update, :destroy]

      def index
        @reviews = @product.product_reviews.includes(:user)
        render json: @reviews, each_serializer: ProductReviewSerializer
      end

      def create
        @review = @product.product_reviews.new(review_params)
        @review.user = current_user
        
        if @review.save
          render json: @review, status: :created
        else
          render json: { errors: @review.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: @review
        else
          render json: { errors: @review.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def destroy
        @review.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def set_review
        @review = @product.product_reviews.find(params[:id])
      end

      def review_params
        params.require(:product_review).permit(
          :rating,
          :title,
          :content,
          :order_id
        )
      end
    end
  end
end
```

## 4. Advanced Features: Search and Filtering

Let's implement a search service:

```ruby
# app/services/product_search_service.rb
class ProductSearchService
  def initialize(params)
    @query = params[:query]
    @category_id = params[:category_id]
    @min_price = params[:min_price]
    @max_price = params[:max_price]
    @sort_by = params[:sort_by]
    @page = params[:page] || 1
    @per_page = params[:per_page] || 20
  end

  def call
    products = Product.active.includes(:category)
    
    products = filter_by_query(products)
    products = filter_by_category(products)
    products = filter_by_price(products)
    products = sort_products(products)
    
    products.page(@page).per(@per_page)
  end

  private

  def filter_by_query(products)
    return products unless @query.present?
    
    products.where(
      'name ILIKE :query OR description ILIKE :query',
      query: "%#{@query}%"
    )
  end

  def filter_by_category(products)
    return products unless @category_id.present?
    
    products.where(category_id: @category_id)
  end

  def filter_by_price(products)
    products = products.where('base_price >= ?', @min_price) if @min_price.present?
    products = products.where('base_price <= ?', @max_price) if @max_price.present?
    products
  end

  def sort_products(products)
    case @sort_by
    when 'price_asc'
      products.order(base_price: :asc)
    when 'price_desc'
      products.order(base_price: :desc)
    when 'newest'
      products.order(created_at: :desc)
    when 'popular'
      products.order(average_rating: :desc)
    else
      products.order(created_at: :desc)
    end
  end
end
```

Would you like me to continue with more advanced features like:
1. Payment Gateway Integration
2. Email Notifications System
3. Admin Dashboard
4. Analytics and Reporting
5. Caching System

Or would you like to focus on testing any of the features we've implemented so far?


I'll guide you through implementing more advanced features, 
starting with Payment Gateway Integration and Email Notifications.

## 1. Payment Gateway Integration

First, let's create a payment service:

```ruby
# app/services/payment_service.rb
class PaymentService
  def initialize(order, payment_method, payment_details)
    @order = order
    @payment_method = payment_method
    @payment_details = payment_details
  end

  def process_payment
    case @payment_method
    when 'credit_card'
      process_credit_card
    when 'paypal'
      process_paypal
    when 'stripe'
      process_stripe
    else
      raise "Unsupported payment method: #{@payment_method}"
    end
  end

  private

  def process_credit_card
    # In a real application, integrate with a payment gateway
    # This is a mock implementation
    payment = Payment.create!(
      order: @order,
      amount: @order.total_amount,
      payment_method: @payment_method,
      status: 'processing'
    )

    # Simulate payment processing
    if valid_credit_card?
      payment.update!(status: 'completed')
      @order.update!(payment_status: 'paid')
      send_payment_confirmation
      true
    else
      payment.update!(status: 'failed')
      @order.update!(payment_status: 'failed')
      false
    end
  end

  def process_paypal
    # PayPal integration would go here
    # Similar structure to credit card processing
  end

  def process_stripe
    # Stripe integration would go here
    # Similar structure to credit card processing
  end

  def valid_credit_card?
    # In a real application, validate with payment gateway
    @payment_details[:card_number].present? &&
    @payment_details[:expiry_date].present? &&
    @payment_details[:cvv].present?
  end
end

# app/models/payment.rb
class Payment < ApplicationRecord
  belongs_to :order

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :status, presence: true

  enum status: {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3,
    refunded: 4
  }

  after_create :log_payment_attempt
  after_update :notify_status_change

  private

  def log_payment_attempt
    PaymentAttempt.create!(
      payment: self,
      status: status,
      details: attributes.except('id', 'created_at', 'updated_at')
    )
  end

  def notify_status_change
    return unless saved_change_to_status?
    
    case status
    when 'completed'
      PaymentMailer.payment_success(self).deliver_later
    when 'failed'
      PaymentMailer.payment_failed(self).deliver_later
    end
  end
end
```

## 2. Email Notifications System

Let's implement a comprehensive email notification system:

```ruby
# app/mailers/order_mailer.rb
class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Order Confirmation - #{@order.order_number}"
    )
  end

  def order_shipped(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Your Order Has Shipped - #{@order.order_number}"
    )
  end

  def order_delivered(order)
    @order = order
    @user = order.user
    
    mail(
      to: @user.email,
      subject: "Your Order Has Been Delivered - #{@order.order_number}"
    )
  end
end

# app/mailers/payment_mailer.rb
class PaymentMailer < ApplicationMailer
  def payment_success(payment)
    @payment = payment
    @order = payment.order
    @user = @order.user
    
    mail(
      to: @user.email,
      subject: "Payment Successful - Order #{@order.order_number}"
    )
  end

  def payment_failed(payment)
    @payment = payment
    @order = payment.order
    @user = @order.user
    
    mail(
      to: @user.email,
      subject: "Payment Failed - Order #{@order.order_number}"
    )
  end
end

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    
    mail(
      to: @user.email,
      subject: 'Welcome to Our Store!'
    )
  end

  def password_reset(user)
    @user = user
    @reset_url = password_reset_url(@user.reset_password_token)
    
    mail(
      to: @user.email,
      subject: 'Password Reset Instructions'
    )
  end

  def account_activity(user, activity)
    @user = user
    @activity = activity
    
    mail(
      to: @user.email,
      subject: 'Account Activity Notification'
    )
  end
end
```

## 3. Admin Dashboard

Let's implement an admin dashboard with analytics:

```ruby
# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_admin!
    
    def index
      @stats = {
        total_orders: Order.count,
        total_revenue: Order.completed.sum(:total_amount),
        total_users: User.count,
        total_products: Product.count
      }
      
      @recent_orders = Order.includes(:user)
                          .order(created_at: :desc)
                          .limit(10)
      
      @top_products = Product.joins(:order_items)
                           .group('products.id')
                           .order('COUNT(order_items.id) DESC')
                           .limit(5)
      
      @sales_data = Order.completed
                        .group_by_day(:created_at, last: 30)
                        .sum(:total_amount)
    end
  end
end

# app/services/admin/analytics_service.rb
module Admin
  class AnalyticsService
    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def sales_report
      {
        total_sales: calculate_total_sales,
        average_order_value: calculate_aov,
        top_products: find_top_products,
        sales_by_category: sales_by_category,
        customer_acquisition: customer_acquisition_data
      }
    end

    private

    def calculate_total_sales
      Order.completed
           .where(created_at: @start_date..@end_date)
           .sum(:total_amount)
    end

    def calculate_aov
      total_orders = Order.completed
                         .where(created_at: @start_date..@end_date)
                         .count
      
      return 0 if total_orders.zero?
      
      calculate_total_sales / total_orders
    end

    def find_top_products
      Product.joins(:order_items)
             .where(order_items: { order: Order.completed.where(created_at: @start_date..@end_date) })
             .group('products.id')
             .order('COUNT(order_items.id) DESC')
             .limit(10)
    end

    def sales_by_category
      Category.joins(products: { order_items: :order })
              .where(orders: { status: :completed, created_at: @start_date..@end_date })
              .group('categories.id')
              .sum('order_items.quantity * order_items.unit_price')
    end

    def customer_acquisition_data
      {
        new_customers: User.where(created_at: @start_date..@end_date).count,
        returning_customers: calculate_returning_customers,
        customer_lifetime_value: calculate_clv
      }
    end

    def calculate_returning_customers
      User.joins(:orders)
          .where(orders: { created_at: @start_date..@end_date })
          .group('users.id')
          .having('COUNT(orders.id) > 1')
          .count
    end

    def calculate_clv
      # Calculate average customer lifetime value
      total_revenue = Order.completed.sum(:total_amount)
      total_customers = User.count
      
      return 0 if total_customers.zero?
      
      total_revenue / total_customers
    end
  end
end
```

## 4. Caching System

Let's implement a caching system for better performance:

```ruby
# app/models/concerns/cacheable.rb
module Cacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_cache
  end

  def cache_key
    "#{self.class.name.downcase}/#{id}-#{updated_at.to_i}"
  end

  def clear_cache
    Rails.cache.delete(cache_key)
    Rails.cache.delete("#{self.class.name.downcase}/all")
  end

  class_methods do
    def cached_find(id)
      Rails.cache.fetch("#{name.downcase}/#{id}") do
        find(id)
      end
    end

    def cached_all
      Rails.cache.fetch("#{name.downcase}/all") do
        all.to_a
      end
    end
  end
end

# app/controllers/concerns/cache_headers.rb
module CacheHeaders
  extend ActiveSupport::Concern

  included do
    after_action :set_cache_headers
  end

  private

  def set_cache_headers
    if action_name == 'show' || action_name == 'index'
      response.headers['Cache-Control'] = 'public, max-age=300'
      response.headers['ETag'] = generate_etag
    end
  end

  def generate_etag
    Digest::MD5.hexdigest(response.body)
  end
end
```

## 5. Background Jobs for Heavy Processing

Let's implement background jobs for heavy processing:

```ruby
# app/jobs/order_processing_job.rb
class OrderProcessingJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    
    # Process payment
    payment_service = PaymentService.new(order, order.payment_method, order.payment_details)
    payment_service.process_payment
    
    # Send confirmation email
    OrderMailer.order_confirmation(order).deliver_later
    
    # Update inventory
    order.order_items.each do |item|
      item.product.update_stock(-item.quantity)
    end
    
    # Generate invoice
    InvoiceGenerationJob.perform_later(order_id)
  end
end

# app/jobs/invoice_generation_job.rb
class InvoiceGenerationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    
    # Generate PDF invoice
    pdf = generate_invoice_pdf(order)
    
    # Store invoice
    order.invoice.attach(
      io: StringIO.new(pdf),
      filename: "invoice_#{order.order_number}.pdf",
      content_type: 'application/pdf'
    )
    
    # Send invoice email
    OrderMailer.invoice(order).deliver_later
  end

  private

  def generate_invoice_pdf(order)
    # Use a PDF generation gem like Prawn
    # This is a simplified example
    Prawn::Document.new do
      text "Invoice ##{order.order_number}"
      text "Date: #{order.created_at}"
      text "Customer: #{order.user.full_name}"
      # Add more invoice details
    end.render
  end
end
```

Would you like me to continue with more advanced features like:
1. API Rate Limiting
2. Webhook System for External Services
3. Real-time Notifications using ActionCable
4. Advanced Search with Elasticsearch
5. Multi-currency Support

Or would you like to focus on testing any of the features we've implemented so far?


I'll guide you through implementing more advanced features, 
starting with API Rate Limiting and Webhook System.

## 1. API Rate Limiting

Let's implement a sophisticated rate limiting system:

```ruby
# app/controllers/concerns/rate_limitable.rb
module RateLimitable
  extend ActiveSupport::Concern

  included do
    before_action :check_rate_limit
  end

  private

  def check_rate_limit
    return unless rate_limit_enabled?

    key = rate_limit_key
    limit = rate_limit_limit
    period = rate_limit_period

    current = redis.get(key).to_i
    if current >= limit
      render json: {
        error: 'Rate limit exceeded',
        retry_after: redis.ttl(key)
      }, status: :too_many_requests
    else
      redis.incr(key)
      redis.expire(key, period) if current.zero?
    end
  end

  def rate_limit_key
    "#{request.remote_ip}:#{controller_name}:#{action_name}"
  end

  def rate_limit_limit
    Rails.application.config.rate_limit.default_limit
  end

  def rate_limit_period
    Rails.application.config.rate_limit.default_period
  end

  def rate_limit_enabled?
    Rails.application.config.rate_limit.enabled
  end

  def redis
    @redis ||= Redis.new(url: Rails.application.config.redis_url)
  end
end

# config/initializers/rate_limit.rb
Rails.application.config.rate_limit = ActiveSupport::OrderedOptions.new
Rails.application.config.rate_limit.enabled = true
Rails.application.config.rate_limit.default_limit = 100
Rails.application.config.rate_limit.default_period = 3600 # 1 hour

# app/models/rate_limit.rb
class RateLimit < ApplicationRecord
  belongs_to :user, optional: true

  validates :key, presence: true, uniqueness: true
  validates :limit, numericality: { greater_than: 0 }
  validates :period, numericality: { greater_than: 0 }

  def exceeded?
    current_count >= limit
  end

  def current_count
    redis.get(key).to_i
  end

  def time_remaining
    redis.ttl(key)
  end

  private

  def redis
    @redis ||= Redis.new(url: Rails.application.config.redis_url)
  end
end
```

## 2. Webhook System for External Services

Let's implement a webhook system for external integrations:

```ruby
# app/models/webhook.rb
class Webhook < ApplicationRecord
  belongs_to :user

  validates :url, presence: true, format: { with: URI::regexp }
  validates :events, presence: true
  validates :secret, presence: true

  before_validation :generate_secret, on: :create

  def deliver(event_type, payload)
    WebhookDeliveryJob.perform_later(id, event_type, payload)
  end

  def verify_signature(payload, signature)
    expected = OpenSSL::HMAC.hexdigest(
      'sha256',
      secret,
      payload
    )
    ActiveSupport::SecurityUtils.secure_compare(signature, expected)
  end

  private

  def generate_secret
    self.secret = SecureRandom.hex(32)
  end
end

# app/jobs/webhook_delivery_job.rb
class WebhookDeliveryJob < ApplicationJob
  queue_as :webhooks

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(webhook_id, event_type, payload)
    webhook = Webhook.find(webhook_id)
    
    response = HTTParty.post(
      webhook.url,
      body: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Webhook-Event' => event_type,
        'X-Webhook-Signature' => generate_signature(webhook, payload)
      }
    )

    WebhookDelivery.create!(
      webhook: webhook,
      event_type: event_type,
      payload: payload,
      response_code: response.code,
      response_body: response.body
    )

    raise "Webhook delivery failed: #{response.code}" unless response.success?
  end

  private

  def generate_signature(webhook, payload)
    OpenSSL::HMAC.hexdigest(
      'sha256',
      webhook.secret,
      payload.to_json
    )
  end
end

# app/models/webhook_delivery.rb
class WebhookDelivery < ApplicationRecord
  belongs_to :webhook

  validates :event_type, presence: true
  validates :payload, presence: true
  validates :response_code, presence: true

  scope :successful, -> { where('response_code >= 200 AND response_code < 300') }
  scope :failed, -> { where('response_code >= 400') }
end
```

## 3. Real-time Notifications using ActionCable

Let's implement real-time notifications:

```ruby
# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :title, presence: true
  validates :message, presence: true

  after_create :broadcast_notification

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read
    update(read_at: Time.current)
  end

  private

  def broadcast_notification
    ActionCable.server.broadcast(
      "notifications_#{user_id}",
      {
        id: id,
        title: title,
        message: message,
        created_at: created_at,
        notifiable_type: notifiable_type,
        notifiable_id: notifiable_id
      }
    )
  end
end

# app/services/notification_service.rb
class NotificationService
  def initialize(user)
    @user = user
  end

  def create_notification(title, message, notifiable = nil)
    Notification.create!(
      user: @user,
      title: title,
      message: message,
      notifiable: notifiable
    )
  end

  def mark_all_as_read
    @user.notifications.unread.update_all(read_at: Time.current)
  end

  def unread_count
    @user.notifications.unread.count
  end
end
```

## 4. Advanced Search with Elasticsearch

Let's implement advanced search functionality:

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :id, type: 'integer'
      indexes :name, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :price, type: 'float'
      indexes :category_id, type: 'integer'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end

    def as_indexed_json(_options = {})
      as_json(
        only: [:id, :name, :description, :price, :category_id, :created_at, :updated_at]
      )
    end
  end

  class_methods do
    def search(query, options = {})
      search_definition = {
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: query,
                  fields: ['name^3', 'description'],
                  fuzziness: 'AUTO'
                }
              }
            ]
          }
        },
        highlight: {
          fields: {
            name: {},
            description: {}
          }
        }
      }

      if options[:filters].present?
        search_definition[:query][:bool][:filter] = options[:filters]
      end

      if options[:sort].present?
        search_definition[:sort] = options[:sort]
      end

      __elasticsearch__.search(search_definition)
    end
  end
end

# app/services/search_service.rb
class SearchService
  def initialize(query, options = {})
    @query = query
    @options = options
  end

  def call
    {
      products: search_products,
      suggestions: generate_suggestions,
      filters: available_filters
    }
  end

  private

  def search_products
    Product.search(@query, build_search_options)
  end

  def generate_suggestions
    # Implement search suggestions logic
    # This could use Elasticsearch's suggest feature
  end

  def available_filters
    {
      categories: Category.all,
      price_ranges: [
        { min: 0, max: 50 },
        { min: 50, max: 100 },
        { min: 100, max: 200 },
        { min: 200, max: nil }
      ]
    }
  end

  def build_search_options
    options = {}
    
    if @options[:category_id].present?
      options[:filters] = { term: { category_id: @options[:category_id] } }
    end

    if @options[:price_range].present?
      options[:filters] = {
        range: {
          price: {
            gte: @options[:price_range][:min],
            lte: @options[:price_range][:max]
          }
        }
      }
    end

    options
  end
end
```

## 5. Multi-currency Support

Let's implement multi-currency support:

```ruby
# app/models/currency.rb
class Currency < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :symbol, presence: true
  validates :exchange_rate, numericality: { greater_than: 0 }

  def self.default
    find_by(code: 'USD') || first
  end

  def convert(amount, target_currency)
    return amount if code == target_currency.code
    
    (amount * exchange_rate / target_currency.exchange_rate).round(2)
  end
end

# app/models/concerns/priceable.rb
module Priceable
  extend ActiveSupport::Concern

  included do
    before_save :normalize_prices
  end

  def price_in(currency_code)
    currency = Currency.find_by(code: currency_code)
    return base_price unless currency
    
    currency.convert(base_price, Currency.default)
  end

  private

  def normalize_prices
    self.base_price = Currency.default.convert(base_price, Currency.default)
  end
end

# app/services/currency_service.rb
class CurrencyService
  def initialize
    @client = ExchangeRateClient.new
  end

  def update_exchange_rates
    rates = @client.fetch_latest_rates
    
    Currency.find_each do |currency|
      rate = rates[currency.code]
      currency.update!(exchange_rate: rate) if rate
    end
  end

  def convert(amount, from_currency, to_currency)
    from = Currency.find_by(code: from_currency)
    to = Currency.find_by(code: to_currency)
    
    return amount unless from && to
    
    from.convert(amount, to)
  end
end

# app/jobs/update_exchange_rates_job.rb
class UpdateExchangeRatesJob < ApplicationJob
  queue_as :default

  def perform
    CurrencyService.new.update_exchange_rates
  end
end
```

Would you like me to continue with more advanced features like:
1. Advanced Caching Strategies
2. API Versioning
3. GraphQL Implementation
4. Microservices Architecture
5. Containerization with Docker

Or would you like to focus on testing any of the features we've implemented so far?


I'll guide you through implementing more advanced features, 
starting with Advanced Caching Strategies and API Versioning.

## 1. Advanced Caching Strategies

Let's implement a sophisticated caching system with different strategies:

```ruby
# app/models/concerns/advanced_cacheable.rb
module AdvancedCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_advanced_cache
  end

  class_methods do
    def cached_find(id, options = {})
      cache_key = generate_cache_key(id, options)
      Rails.cache.fetch(cache_key, expires_in: options[:expires_in] || 1.hour) do
        includes(options[:includes]).find(id)
      end
    end

    def cached_where(conditions, options = {})
      cache_key = generate_cache_key(conditions, options)
      Rails.cache.fetch(cache_key, expires_in: options[:expires_in] || 1.hour) do
        includes(options[:includes]).where(conditions)
      end
    end

    def cached_count(conditions = nil, options = {})
      cache_key = generate_cache_key(['count', conditions], options)
      Rails.cache.fetch(cache_key, expires_in: options[:expires_in] || 1.hour) do
        where(conditions).count
      end
    end

    private

    def generate_cache_key(identifier, options)
      [
        name.underscore,
        identifier,
        options[:version],
        options[:locale],
        options[:user_id]
      ].compact.join('/')
    end
  end

  private

  def clear_advanced_cache
    # Clear specific caches
    Rails.cache.delete_matched("#{self.class.name.underscore}/#{id}/*")
    
    # Clear related caches
    self.class.reflect_on_all_associations.each do |association|
      Rails.cache.delete_matched("#{association.klass.name.underscore}/*")
    end
  end
end

# app/services/cache_service.rb
class CacheService
  def initialize(model_class)
    @model_class = model_class
  end

  def warm_cache(scope = :all)
    @model_class.send(scope).find_each do |record|
      Rails.cache.write(
        record.cache_key,
        record,
        expires_in: 1.hour
      )
    end
  end

  def clear_cache(pattern = nil)
    if pattern
      Rails.cache.delete_matched(pattern)
    else
      Rails.cache.delete_matched("#{@model_class.name.underscore}/*")
    end
  end

  def cache_stats
    {
      hits: Rails.cache.stats[:hits],
      misses: Rails.cache.stats[:misses],
      size: Rails.cache.stats[:size]
    }
  end
end

# app/jobs/cache_warming_job.rb
class CacheWarmingJob < ApplicationJob
  queue_as :low_priority

  def perform(model_class, scope = :all)
    CacheService.new(model_class).warm_cache(scope)
  end
end
```

## 2. API Versioning

Let's implement a robust API versioning system:

```ruby
# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    include Api::Versioning
    include Api::ErrorHandling

    before_action :set_version
    before_action :validate_version

    private

    def set_version
      @version = request.headers['Accept'].match(/version=(\d+)/)&.captures&.first || '1'
    end

    def validate_version
      unless valid_version?(@version)
        render json: {
          error: "Invalid API version. Available versions: #{available_versions.join(', ')}"
        }, status: :bad_request
      end
    end
  end
end

# app/controllers/concerns/api/versioning.rb
module Api
  module Versioning
    extend ActiveSupport::Concern

    def versioned_serializer(record)
      "Api::V#{@version}::#{record.class.name}Serializer".constantize
    rescue NameError
      "Api::V1::#{record.class.name}Serializer".constantize
    end

    def versioned_controller
      "Api::V#{@version}::#{controller_name.classify}Controller".constantize
    rescue NameError
      "Api::V1::#{controller_name.classify}Controller".constantize
    end

    private

    def valid_version?(version)
      available_versions.include?(version)
    end

    def available_versions
      Rails.application.config.api_versions
    end
  end
end

# config/initializers/api_versioning.rb
Rails.application.config.api_versions = ['1', '2']

# app/controllers/api/v2/products_controller.rb
module Api
  module V2
    class ProductsController < Api::BaseController
      def index
        @products = Product.includes(:category, :variants)
                         .filter(filter_params)
                         .sort(sort_params)
                         .page(params[:page])
                         .per(params[:per_page])

        render json: @products, each_serializer: versioned_serializer(Product)
      end

      private

      def filter_params
        params.permit(:category_id, :min_price, :max_price, :in_stock)
      end

      def sort_params
        params.permit(:sort_by, :sort_direction)
      end
    end
  end
end

# app/serializers/api/v2/product_serializer.rb
module Api
  module V2
    class ProductSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :price, :stock_quantity
      belongs_to :category
      has_many :variants
      
      def price
        object.price_in(current_user.currency)
      end
    end
  end
end
```

## 3. GraphQL Implementation

Let's implement a GraphQL API:

```ruby
# app/graphql/types/base_object.rb
module Types
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField
  end
end

# app/graphql/types/product_type.rb
module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :price, Float, null: false
    field :stock_quantity, Int, null: false
    field :category, Types::CategoryType, null: true
    field :variants, [Types::ProductVariantType], null: true
    field :reviews, [Types::ReviewType], null: true
    field :average_rating, Float, null: true

    def price
      object.price_in(context[:current_user].currency)
    end
  end
end

# app/graphql/mutations/create_product.rb
module Mutations
  class CreateProduct < Mutations::BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :price, Float, required: true
    argument :category_id, ID, required: true
    argument :stock_quantity, Int, required: true

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(**attributes)
      authorize! :create, Product
      
      product = Product.new(attributes)
      
      if product.save
        {
          product: product,
          errors: []
        }
      else
        {
          product: nil,
          errors: product.errors.full_messages
        }
      end
    end
  end
end

# app/graphql/query_type.rb
module Types
  class QueryType < Types::BaseObject
    field :products, [Types::ProductType], null: false do
      argument :category_id, ID, required: false
      argument :min_price, Float, required: false
      argument :max_price, Float, required: false
    end

    field :product, Types::ProductType, null: true do
      argument :id, ID, required: true
    end

    def products(**args)
      Product.search(args)
    end

    def product(id:)
      Product.find(id)
    end
  end
end
```

## 4. Microservices Architecture

Let's implement a microservices communication layer:

```ruby
# app/services/microservice_client.rb
class MicroserviceClient
  def initialize(service_name)
    @service_name = service_name
    @base_url = Rails.application.config.microservices[service_name]
  end

  def get(path, params = {})
    request(:get, path, params)
  end

  def post(path, data = {})
    request(:post, path, data)
  end

  private

  def request(method, path, data = {})
    response = connection.send(method) do |req|
      req.url path
      req.headers['Authorization'] = "Bearer #{generate_token}"
      req.params = data if method == :get
      req.body = data.to_json if method == :post
    end

    handle_response(response)
  end

  def connection
    @connection ||= Faraday.new(url: @base_url) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end

  def generate_token
    JWT.encode(
      {
        service: 'ecommerce',
        exp: 1.hour.from_now.to_i
      },
      Rails.application.credentials.jwt_secret
    )
  end

  def handle_response(response)
    case response.status
    when 200..299
      response.body
    when 401
      raise MicroserviceClient::UnauthorizedError
    when 404
      raise MicroserviceClient::NotFoundError
    else
      raise MicroserviceClient::Error, response.body['error']
    end
  end
end

# app/services/inventory_service.rb
class InventoryService
  def initialize
    @client = MicroserviceClient.new('inventory')
  end

  def check_stock(product_id, quantity)
    @client.get("/products/#{product_id}/stock", quantity: quantity)
  end

  def update_stock(product_id, quantity)
    @client.post("/products/#{product_id}/stock", quantity: quantity)
  end
end

# app/services/payment_service.rb
class PaymentService
  def initialize
    @client = MicroserviceClient.new('payment')
  end

  def process_payment(order_id, amount, payment_method)
    @client.post('/payments', {
      order_id: order_id,
      amount: amount,
      payment_method: payment_method
    })
  end
end
```

## 5. Containerization with Docker

Let's set up Docker configuration:

```dockerfile
# Dockerfile
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile* ./
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start server
CMD ["rails", "server", "-b", "0.0.0.0"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/ecommerce_development
      - REDIS_URL=redis://redis:6379/1
    depends_on:
      - db
      - redis

  db:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=ecommerce_development

  redis:
    image: redis:7
    volumes:
      - redis_data:/data

  sidekiq:
    build: .
    command: bundle exec sidekiq -C config/sidekiq.yml
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/ecommerce_development
      - REDIS_URL=redis://redis:6379/1
    depends_on:
      - app
      - redis

volumes:
  postgres_data:
  redis_data:
```

Would you like me to continue with more advanced features like:
1. Advanced Security Features
2. Performance Monitoring
3. A/B Testing Framework
4. Feature Flags System
5. Advanced Search with Elasticsearch

Or would you like to focus on testing any of the features we've implemented so far?



Excellent! Let's enhance our e-commerce platform by implementing these microservices architecture concepts. 
I'll guide you through setting up the core microservices and additional components.

## 1. Microservices Setup

First, let's create a directory structure for our microservices:

```ruby
# Directory Structure
ecommerce-platform/
├── api-gateway/
├── user-service/
├── product-service/
├── cart-service/
├── order-service/
├── payment-service/
├── notification-service/
├── docker-compose.yml
└── README.md
```

Let's start with the API Gateway configuration:

```ruby
# api-gateway/config/routes.rb
Rails.application.routes.draw do
  scope '/api' do
    # User Service Routes
    mount UserService::Engine, at: '/users'
    
    # Product Service Routes
    mount ProductService::Engine, at: '/products'
    
    # Cart Service Routes
    mount CartService::Engine, at: '/cart'
    
    # Order Service Routes
    mount OrderService::Engine, at: '/orders'
    
    # Payment Service Routes
    mount PaymentService::Engine, at: '/payments'
  end
end

# api-gateway/app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    include Api::ErrorHandling
    include Api::Authentication
    
    before_action :authenticate_request
    before_action :set_service_client
    
    private
    
    def set_service_client
      @service_client = ServiceClient.new(request.headers['Authorization'])
    end
  end
end
```

## 2. User Service Implementation

```ruby
# user-service/app/models/user.rb
class User < ApplicationRecord
  include JWT::Auth::Authenticatable
  
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
  
  has_one :profile
  has_many :addresses
  has_many :orders
  
  def generate_jwt
    JWT.encode(
      {
        user_id: id,
        exp: 24.hours.from_now.to_i
      },
      Rails.application.credentials.jwt_secret
    )
  end
end

# user-service/app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      def create
        @user = User.new(user_params)
        
        if @user.save
          render json: {
            user: UserSerializer.new(@user),
            token: @user.generate_jwt
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(
          :email,
          :password,
          :first_name,
          :last_name
        )
      end
    end
  end
end
```

## 3. Product Service Implementation

```ruby
# product-service/app/models/product.rb
class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  belongs_to :category
  has_many :variants
  has_many :reviews
  
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  
  mapping do
    indexes :name, type: 'text'
    indexes :description, type: 'text'
    indexes :price, type: 'float'
    indexes :category_id, type: 'integer'
  end
end

# product-service/app/controllers/api/v1/products_controller.rb
module Api
  module V1
    class ProductsController < ApplicationController
      def index
        @products = Product.search(
          query: {
            bool: {
              must: [
                {
                  multi_match: {
                    query: params[:query],
                    fields: ['name^3', 'description']
                  }
                }
              ],
              filter: filter_params
            }
          }
        )
        
        render json: @products, each_serializer: ProductSerializer
      end
    end
  end
end
```

## 4. Cart Service Implementation

```ruby
# cart-service/app/models/cart.rb
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items
  
  def add_item(product_id, quantity = 1)
    cart_item = cart_items.find_or_initialize_by(product_id: product_id)
    
    with_lock do
      if cart_item.new_record?
        cart_item.quantity = quantity
      else
        cart_item.quantity += quantity
      end
      
      cart_item.save!
    end
  end
  
  def total_price
    cart_items.sum { |item| item.quantity * item.unit_price }
  end
end

# cart-service/app/controllers/api/v1/cart_items_controller.rb
module Api
  module V1
    class CartItemsController < ApplicationController
      def create
        @cart_item = current_cart.cart_items.new(cart_item_params)
        
        if @cart_item.save
          render json: @cart_item, status: :created
        else
          render json: { errors: @cart_item.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
```

## 5. Order Service Implementation

```ruby
# order-service/app/models/order.rb
class Order < ApplicationRecord
  include AASM
  
  belongs_to :user
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :billing_address, class_name: 'Address'
  has_many :order_items
  
  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :shipped
    state :delivered
    state :cancelled
    
    event :process do
      transitions from: :pending, to: :processing
    end
    
    event :ship do
      transitions from: :processing, to: :shipped
    end
    
    event :deliver do
      transitions from: :shipped, to: :delivered
    end
    
    event :cancel do
      transitions from: [:pending, :processing], to: :cancelled
    end
  end
end

# order-service/app/controllers/api/v1/orders_controller.rb
module Api
  module V1
    class OrdersController < ApplicationController
      def create
        @order = current_user.orders.new(order_params)
        
        if @order.save
          # Notify payment service
          PaymentService.new(@order).process_payment
          
          render json: @order, status: :created
        else
          render json: { errors: @order.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
```

## 6. Docker Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  api-gateway:
    build: ./api-gateway
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/api_gateway
    depends_on:
      - db
      - redis

  user-service:
    build: ./user-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/user_service
    depends_on:
      - db

  product-service:
    build: ./product-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/product_service
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - db
      - elasticsearch

  cart-service:
    build: ./cart-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/cart_service
      - REDIS_URL=redis://redis:6379/1
    depends_on:
      - db
      - redis

  order-service:
    build: ./order-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/order_service
    depends_on:
      - db
      - redis

  payment-service:
    build: ./payment-service
    environment:
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
    depends_on:
      - redis

  notification-service:
    build: ./notification-service
    environment:
      - SENDGRID_API_KEY=${SENDGRID_API_KEY}
    depends_on:
      - redis

  db:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password

  redis:
    image: redis:7
    volumes:
      - redis_data:/data

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:
```

## 7. Service Discovery with Consul

```ruby
# config/initializers/consul.rb
require 'diplomat'

Diplomat.configure do |config|
  config.url = ENV['CONSUL_URL'] || 'http://consul:8500'
end

# app/services/service_discovery.rb
class ServiceDiscovery
  def self.register_service(service_name, port)
    Diplomat::Service.register(
      name: service_name,
      port: port,
      tags: ['rails', 'api'],
      check: {
        http: "http://localhost:#{port}/health",
        interval: '10s',
        timeout: '5s'
      }
    )
  end

  def self.discover_service(service_name)
    Diplomat::Service.get(service_name)
  end
end
```

Would you like me to continue with:
1. Setting up the CI/CD pipeline
2. Implementing centralized logging with ELK stack
3. Adding monitoring with Prometheus and Grafana
4. Implementing the notification service with SendGrid
5. Setting up the payment service with Stripe

Or would you like to focus on any specific aspect of the microservices architecture?


I'll guide you through implementing all five components. Let's start with each one systematically.

## 1. CI/CD Pipeline Setup

First, let's set up GitHub Actions for our CI/CD pipeline:

```yaml
# .github/workflows/main.yml
name: E-commerce Platform CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.2.2'
        bundler-cache: true
        
    - name: Install dependencies
      run: bundle install
      
    - name: Setup database
      env:
        RAILS_ENV: test
        DATABASE_URL: postgres://postgres:password@localhost:5432/ecommerce_test
      run: |
        bundle exec rails db:create
        bundle exec rails db:schema:load
        
    - name: Run tests
      env:
        RAILS_ENV: test
        DATABASE_URL: postgres://postgres:password@localhost:5432/ecommerce_test
      run: bundle exec rspec

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1
      
    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    - name: Build and push
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: ${{ secrets.DOCKERHUB_USERNAME }}/ecommerce:${{ github.sha }}
```

## 2. Centralized Logging with ELK Stack

Let's set up the ELK stack for centralized logging:

```yaml
# docker-compose.logging.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

```ruby
# config/initializers/logging.rb
require 'logstash-logger'

Rails.application.configure do
  config.logger = LogStashLogger.new(
    type: :tcp,
    host: ENV['LOGSTASH_HOST'] || 'logstash',
    port: ENV['LOGSTASH_PORT'] || 5000
  )
end

# app/controllers/concerns/loggable.rb
module Loggable
  extend ActiveSupport::Concern

  included do
    around_action :log_request
  end

  private

  def log_request
    start_time = Time.current
    yield
    duration = Time.current - start_time

    log_data = {
      timestamp: Time.current,
      service: Rails.application.class.module_parent_name,
      request_id: request.request_id,
      method: request.method,
      path: request.path,
      params: request.params.except('controller', 'action'),
      status: response.status,
      duration: duration,
      user_id: current_user&.id
    }

    Rails.logger.info(log_data)
  end
end
```

## 3. Monitoring with Prometheus and Grafana

Let's set up monitoring:

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    depends_on:
      - prometheus

volumes:
  grafana_data:
```

```ruby
# config/initializers/prometheus.rb
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

Rails.application.middleware.use Prometheus::Middleware::Collector
Rails.application.middleware.use Prometheus::Middleware::Exporter

# app/controllers/concerns/metrics.rb
module Metrics
  extend ActiveSupport::Concern

  included do
    before_action :record_request_metrics
    after_action :record_response_metrics
  end

  private

  def record_request_metrics
    @request_start_time = Time.current
  end

  def record_response_metrics
    duration = Time.current - @request_start_time
    
    Prometheus::Client.registry.get(:http_request_duration_seconds)
      .observe(duration, labels: {
        method: request.method,
        path: request.path,
        status: response.status
      })
  end
end
```

## 4. Notification Service with SendGrid

Let's implement the notification service:

```ruby
# notification-service/app/services/notification_service.rb
class NotificationService
  def initialize
    @client = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def send_email(to, template_id, data)
    mail = SendGrid::Mail.new
    mail.from = SendGrid::Email.new(email: 'noreply@ecommerce.com')
    mail.template_id = template_id
    
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: to))
    personalization.add_dynamic_template_data(data)
    mail.add_personalization(personalization)
    
    @client.client.mail._('send').post(request_body: mail.to_json)
  end

  def send_sms(to, message)
    client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    
    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: to,
      body: message
    )
  end
end

# notification-service/app/jobs/notification_job.rb
class NotificationJob < ApplicationJob
  queue_as :notifications

  def perform(notification_type, recipient, data)
    case notification_type
    when :order_confirmation
      send_order_confirmation(recipient, data)
    when :shipping_update
      send_shipping_update(recipient, data)
    when :payment_received
      send_payment_confirmation(recipient, data)
    end
  end

  private

  def send_order_confirmation(recipient, data)
    NotificationService.new.send_email(
      recipient,
      'order_confirmation_template_id',
      {
        order_number: data[:order_number],
        total_amount: data[:total_amount],
        items: data[:items]
      }
    )
  end

  def send_shipping_update(recipient, data)
    NotificationService.new.send_email(
      recipient,
      'shipping_update_template_id',
      {
        order_number: data[:order_number],
        tracking_number: data[:tracking_number],
        status: data[:status]
      }
    )
  end

  def send_payment_confirmation(recipient, data)
    NotificationService.new.send_email(
      recipient,
      'payment_confirmation_template_id',
      {
        order_number: data[:order_number],
        amount: data[:amount],
        payment_method: data[:payment_method]
      }
    )
  end
end
```

## 5. Payment Service with Stripe

Let's implement the payment service:

```ruby
# payment-service/app/services/stripe_service.rb
class StripeService
  def initialize
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end

  def create_payment_intent(amount, currency, metadata = {})
    Stripe::PaymentIntent.create(
      amount: amount,
      currency: currency,
      metadata: metadata,
      automatic_payment_methods: {
        enabled: true
      }
    )
  end

  def create_customer(email, payment_method_id)
    customer = Stripe::Customer.create(
      email: email,
      payment_method: payment_method_id
    )
    
    Stripe::PaymentMethod.attach(
      payment_method_id,
      customer: customer.id
    )
    
    customer
  end

  def process_payment(payment_intent_id)
    payment_intent = Stripe::PaymentIntent.confirm(payment_intent_id)
    
    if payment_intent.status == 'succeeded'
      {
        success: true,
        payment_id: payment_intent.id,
        amount: payment_intent.amount,
        currency: payment_intent.currency
      }
    else
      {
        success: false,
        error: payment_intent.last_payment_error&.message
      }
    end
  end
end

# payment-service/app/controllers/api/v1/payments_controller.rb
module Api
  module V1
    class PaymentsController < ApplicationController
      def create
        payment_intent = stripe_service.create_payment_intent(
          params[:amount],
          params[:currency],
          params[:metadata]
        )
        
        render json: {
          client_secret: payment_intent.client_secret
        }
      end

      def confirm
        result = stripe_service.process_payment(params[:payment_intent_id])
        
        if result[:success]
          # Notify order service
          OrderService.new.update_payment_status(
            result[:payment_id],
            'completed'
          )
          
          render json: { status: 'success' }
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      private

      def stripe_service
        @stripe_service ||= StripeService.new
      end
    end
  end
end
```

## Integration of All Services

Let's create a service orchestration layer:

```ruby
# api-gateway/app/services/orchestration_service.rb
class OrchestrationService
  def initialize(order_id)
    @order = Order.find(order_id)
  end

  def process_order
    # 1. Validate order
    validate_order
    
    # 2. Process payment
    payment_result = process_payment
    
    # 3. Update inventory
    update_inventory if payment_result[:success]
    
    # 4. Send notifications
    send_notifications(payment_result)
    
    # 5. Log the transaction
    log_transaction(payment_result)
  end

  private

  def validate_order
    OrderValidationService.new(@order).validate
  end

  def process_payment
    PaymentService.new.process_payment(@order)
  end

  def update_inventory
    InventoryService.new.update_stock(@order)
  end

  def send_notifications(payment_result)
    NotificationService.new.send_order_confirmation(@order, payment_result)
  end

  def log_transaction(payment_result)
    TransactionLogService.new.log(@order, payment_result)
  end
end
```

Would you like me to:
1. Add more detailed error handling and retry mechanisms
2. Implement circuit breakers for service resilience
3. Add API documentation with Swagger/OpenAPI
4. Implement rate limiting and throttling
5. Add security features like JWT validation and API key management

Or would you like to focus on any specific aspect of these implementations?


Absolutely! I can help you set up a local development environment for your e-commerce platform, including all the advanced features and CI/CD pipeline, so you can work offline. Here’s a step-by-step guide to get everything running on your local machine.

### Local Development Environment Setup

#### 1. Prerequisites

Make sure you have the following installed on your laptop:

- **Docker**: For containerization of services.
- **Docker Compose**: To manage multi-container applications.
- **Ruby**: For the Rails application (if you want to run it outside of Docker).
- **PostgreSQL**: For the database (if not using Docker).
- **Redis**: For caching (if not using Docker).
- **Node.js**: For JavaScript runtime (if needed for asset compilation).

#### 2. Directory Structure

Create a directory for your e-commerce platform:

```bash
mkdir ecommerce-platform
cd ecommerce-platform
```

Inside this directory, create subdirectories for each service:

```bash
mkdir api-gateway user-service product-service cart-service order-service payment-service notification-service
```

#### 3. Docker Configuration

Create a `docker-compose.yml` file in the root of your `ecommerce-platform` directory:

```yaml
version: '3.8'

services:
  api-gateway:
    build: ./api-gateway
    ports:
      - "3000:3000"
    depends_on:
      - user-service
      - product-service
      - cart-service
      - order-service
      - payment-service
      - notification-service

  user-service:
    build: ./user-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/user_service
    depends_on:
      - db

  product-service:
    build: ./product-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/product_service
    depends_on:
      - db

  cart-service:
    build: ./cart-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/cart_service
    depends_on:
      - db

  order-service:
    build: ./order-service
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/order_service
    depends_on:
      - db

  payment-service:
    build: ./payment-service
    environment:
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
    depends_on:
      - redis

  notification-service:
    build: ./notification-service
    environment:
      - SENDGRID_API_KEY=${SENDGRID_API_KEY}
    depends_on:
      - redis

  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

#### 4. Service Configuration

Each service should have its own `Dockerfile`. Here’s an example for the `user-service`:

```dockerfile
# user-service/Dockerfile
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile* ./
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start server
CMD ["rails", "server", "-b", "0.0.0.0"]
```

Repeat this for each service, adjusting the `Dockerfile` as necessary.

#### 5. CI/CD Pipeline Setup

For local CI/CD, you can use GitHub Actions, but since you want to work offline, consider using a local CI tool like **GitLab CI** or **Jenkins**. Here’s how to set up a simple GitLab CI configuration:

1. **Install GitLab Runner** on your local machine.
2. Create a `.gitlab-ci.yml` file in the root of your project:

```yaml
stages:
  - test
  - deploy

test:
  stage: test
  script:
    - docker-compose up -d db
    - docker-compose run api-gateway bundle exec rspec
  services:
    - postgres:14

deploy:
  stage: deploy
  script:
    - echo "Deploying to local environment..."
```

#### 6. Running the Application

To run your application locally, use the following command:

```bash
docker-compose up --build
```

This command will build and start all your services. You can access the API Gateway at `http://localhost:3000`.

#### 7. Testing the Application

You can run tests for each service using:

```bash
docker-compose run user-service bundle exec rspec
```

Repeat this for each service as needed.

#### 8. Advanced Features Implementation

Now, you can implement the advanced features we discussed earlier:

1. **Advanced Error Handling**: Implement custom error classes and middleware for handling errors gracefully.
2. **Circuit Breakers**: Use a gem like `circuitbox` to implement circuit breakers for external service calls.
3. **API Documentation**: Use Swagger or OpenAPI to document your API endpoints.
4. **Rate Limiting**: Implement rate limiting using middleware or a gem like `rack-attack`.
5. **Security Features**: Implement JWT validation, API key management, and secure your endpoints.

### Final Steps

1. **Testing**: Ensure all features are thoroughly tested.
2. **Documentation**: Document your setup and usage instructions in a `README.md` file.
3. **Backup**: Regularly back up your database and important files.

### Example README.md

```markdown
# E-commerce Platform

## Setup Instructions

1. Clone the repository.
2. Navigate to the project directory.
3. Run `docker-compose up --build` to start the application.
4. Access the API Gateway at `http://localhost:3000`.

## Running Tests

To run tests for a specific service, use:

```bash
docker-compose run user-service bundle exec rspec
```

## CI/CD

This project includes a CI/CD pipeline using GitLab CI. Ensure you have GitLab Runner installed locally.

## Advanced Features

- Rate Limiting
- Circuit Breakers
- API Documentation
- Security Features
```

This setup will allow you to work on your e-commerce platform locally, 
including all advanced features and CI/CD capabilities. If you have any specific questions or need further 
assistance with any part of the setup, feel free to ask!


Yes, we can perform integration testing using curl commands. 
I'll provide a comprehensive set of curl commands to test various endpoints of your e-commerce API:

### 1. Authentication Endpoints

```bash
# Register a new user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "testuser",
      "email": "test@example.com",
      "password": "Password123",
      "first_name": "Test",
      "last_name": "User"
    }
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123"
  }'

curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "lemuel@example.com",
    "password": "Password123"
  }'

# Refresh token
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "your_refresh_token"
  }'
```

### 2. Product Endpoints

```bash
# Get all products
curl -X GET http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer your_access_token"

# Get a specific product
curl -X GET http://localhost:3000/api/v1/products/1 \
  -H "Authorization: Bearer your_access_token"

# Search products
curl -X GET "http://localhost:3000/api/v1/products/search?q=phone" \
  -H "Authorization: Bearer your_access_token"
```

### 3. Review Endpoints

```bash
# Get product reviews
curl -X GET http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token"

# Create a review
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Great product!",
      "content": "This product exceeded my expectations.",
      "rating": 5
    }
  }'

# Get review statistics
curl -X GET http://localhost:3000/api/v1/products/1/reviews/statistics \
  -H "Authorization: Bearer your_access_token"
```

### 4. Order Endpoints

```bash
# Create an order
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "address_id": 1,
      "order_items": [
        {
          "product_variant_id": 1,
          "quantity": 2
        }
      ]
    }
  }'

# Get user orders
curl -X GET http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer your_access_token"

# Cancel an order
curl -X POST http://localhost:3000/api/v1/orders/1/cancel \
  -H "Authorization: Bearer your_access_token"
```

### 5. Admin Endpoints

```bash
# Get dashboard statistics
curl -X GET http://localhost:3000/api/v1/admin/dashboard/statistics \
  -H "Authorization: Bearer admin_access_token"

# Get pending reviews
curl -X GET http://localhost:3000/api/v1/admin/products/1/reviews/pending \
  -H "Authorization: Bearer admin_access_token"

# Approve a review
curl -X POST http://localhost:3000/api/v1/admin/products/1/reviews/1/approve \
  -H "Authorization: Bearer admin_access_token"

# Get review analytics
curl -X GET "http://localhost:3000/api/v1/admin/reviews/analytics?start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer admin_access_token"
```

### 6. Cart Endpoints

```bash
# Add to cart
curl -X POST http://localhost:3000/api/v1/cart_items \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "cart_item": {
      "product_variant_id": 1,
      "quantity": 1
    }
  }'

# Update cart item
curl -X PATCH http://localhost:3000/api/v1/cart_items/1 \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "cart_item": {
      "quantity": 2
    }
  }'
```

### 7. Wishlist Endpoints

```bash
# Add to wishlist
curl -X POST http://localhost:3000/api/v1/wishlists \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "wishlist": {
      "product_id": 1
    }
  }'
```

### 8. Review Recommendations

```bash
# Get personalized recommendations
curl -X GET http://localhost:3000/api/v1/reviews/recommendations \
  -H "Authorization: Bearer your_access_token"
```

### Testing Tips:

1. **Save Tokens**: After login, save the access token and refresh token for subsequent requests:
```bash
# Save tokens to environment variables
export ACCESS_TOKEN="your_access_token"
export REFRESH_TOKEN="your_refresh_token"

# Use in curl commands
curl -H "Authorization: Bearer $ACCESS_TOKEN" ...
```

2. **Test Error Cases**:
```bash
# Test invalid token
curl -X GET http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer invalid_token"

# Test rate limiting
for i in {1..6}; do
  curl -X GET http://localhost:3000/api/v1/products \
    -H "Authorization: Bearer your_access_token"
done
```

3. **Test Validation**:
```bash
# Test invalid review rating
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Great product!",
      "content": "This product exceeded my expectations.",
      "rating": 6
    }
  }'
```

4. **Test Pagination**:
```bash
# Test paginated endpoints
curl -X GET "http://localhost:3000/api/v1/products?page=2&per_page=10" \
  -H "Authorization: Bearer your_access_token"
```


I'll provide a comprehensive list of edge cases and specific test scenarios for your e-commerce API. 
These tests will help ensure the robustness and reliability of your system:

### 1. Authentication Edge Cases

```bash
# 1. Invalid Credentials
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nonexistent@example.com",
    "password": "wrongpassword"
  }'

# 2. Malformed Email
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "testuser",
      "email": "invalid-email",
      "password": "Password123"
    }
  }'

# 3. Weak Password
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "testuser",
      "email": "test@example.com",
      "password": "123"
    }
  }'

# 4. Expired Token
curl -X GET http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer expired_token"

# 5. Multiple Login Attempts (Rate Limiting)
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@example.com",
      "password": "wrongpassword"
    }'
done
```

### 2. Product Edge Cases

```bash
# 1. Out of Stock Product
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "address_id": 1,
      "order_items": [
        {
          "product_variant_id": 1,
          "quantity": 999999
        }
      ]
    }
  }'

# 2. Negative Quantity
curl -X POST http://localhost:3000/api/v1/cart_items \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "cart_item": {
      "product_variant_id": 1,
      "quantity": -1
    }
  }'

# 3. Non-existent Product
curl -X GET http://localhost:3000/api/v1/products/999999 \
  -H "Authorization: Bearer your_access_token"

# 4. Large Search Query
curl -X GET "http://localhost:3000/api/v1/products/search?q=$(printf 'a%.0s' {1..1000})" \
  -H "Authorization: Bearer your_access_token"
```

### 3. Review Edge Cases

```bash
# 1. Duplicate Review
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Great product!",
      "content": "This product exceeded my expectations.",
      "rating": 5
    }
  }'

# 2. Extreme Rating Values
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Terrible!",
      "content": "Worst product ever.",
      "rating": 0
    }
  }'

# 3. Very Long Review Content
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Long Review",
      "content": "$(printf 'a%.0s' {1..2000})",
      "rating": 5
    }
  }'

# 4. Review with Special Characters
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Special Chars!@#$%^&*()",
      "content": "Contains special characters: !@#$%^&*()",
      "rating": 5
    }
  }'
```

### 4. Order Edge Cases

```bash
# 1. Empty Order
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "address_id": 1,
      "order_items": []
    }
  }'

# 2. Cancel Completed Order
curl -X POST http://localhost:3000/api/v1/orders/1/cancel \
  -H "Authorization: Bearer your_access_token"

# 3. Order with Multiple Same Items
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "address_id": 1,
      "order_items": [
        {
          "product_variant_id": 1,
          "quantity": 1
        },
        {
          "product_variant_id": 1,
          "quantity": 1
        }
      ]
    }
  }'
```

### 5. Cart Edge Cases

```bash
# 1. Add Same Item Multiple Times
for i in {1..3}; do
  curl -X POST http://localhost:3000/api/v1/cart_items \
    -H "Authorization: Bearer your_access_token" \
    -H "Content-Type: application/json" \
    -d '{
      "cart_item": {
        "product_variant_id": 1,
        "quantity": 1
      }
    }'
done

# 2. Update to Zero Quantity
curl -X PATCH http://localhost:3000/api/v1/cart_items/1 \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "cart_item": {
      "quantity": 0
    }
  }'
```

### 6. Admin Edge Cases

```bash
# 1. Non-admin Accessing Admin Endpoints
curl -X GET http://localhost:3000/api/v1/admin/dashboard/statistics \
  -H "Authorization: Bearer regular_user_token"

# 2. Approve Already Approved Review
curl -X POST http://localhost:3000/api/v1/admin/products/1/reviews/1/approve \
  -H "Authorization: Bearer admin_access_token"

# 3. Delete Non-existent Review
curl -X DELETE http://localhost:3000/api/v1/admin/products/1/reviews/999999 \
  -H "Authorization: Bearer admin_access_token"
```

### 7. Rate Limiting Edge Cases

```bash
# 1. Rapid Successive Requests
for i in {1..20}; do
  curl -X GET http://localhost:3000/api/v1/products \
    -H "Authorization: Bearer your_access_token" &
done

# 2. Different IP Addresses (Simulated)
for i in {1..5}; do
  curl -X GET http://localhost:3000/api/v1/products \
    -H "Authorization: Bearer your_access_token" \
    -H "X-Forwarded-For: 192.168.1.$i"
done
```

### 8. Data Validation Edge Cases

```bash
# 1. SQL Injection Attempt
curl -X GET "http://localhost:3000/api/v1/products/search?q=' OR '1'='1" \
  -H "Authorization: Bearer your_access_token"

# 2. XSS Attempt
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "<script>alert('xss')</script>",
      "content": "Normal content",
      "rating": 5
    }
  }'

# 3. JSON Injection
curl -X POST http://localhost:3000/api/v1/products/1/reviews \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "product_review": {
      "title": "Normal title",
      "content": "Normal content",
      "rating": 5,
      "metadata": {"malicious": "data"}
    }
  }'
```

### 9. Concurrency Edge Cases

```bash
# 1. Simultaneous Stock Updates
for i in {1..5}; do
  curl -X POST http://localhost:3000/api/v1/orders \
    -H "Authorization: Bearer your_access_token" \
    -H "Content-Type: application/json" \
    -d '{
      "order": {
        "address_id": 1,
        "order_items": [
          {
            "product_variant_id": 1,
            "quantity": 1
          }
        ]
      }
    }' &
done

# 2. Simultaneous Review Creation
for i in {1..5}; do
  curl -X POST http://localhost:3000/api/v1/products/1/reviews \
    -H "Authorization: Bearer your_access_token" \
    -H "Content-Type: application/json" \
    -d '{
      "product_review": {
        "title": "Review $i",
        "content": "Content $i",
        "rating": 5
      }
    }' &
done
```

These edge cases cover various scenarios including:
- Invalid inputs
- Security vulnerabilities
- Race conditions
- Rate limiting
- Data validation
- Authorization issues
- Resource constraints
- Concurrency issues

