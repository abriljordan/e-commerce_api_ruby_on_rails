class AddAdminFeatures < ActiveRecord::Migration[7.1]
  def change
    # Add order status and tracking
    add_column :orders, :status, :string, default: 'pending' unless column_exists?(:orders, :status)
    add_column :orders, :tracking_number, :string unless column_exists?(:orders, :tracking_number)
    add_column :orders, :shipping_carrier, :string unless column_exists?(:orders, :shipping_carrier)
    add_column :orders, :total_amount, :decimal, precision: 10, scale: 2 unless column_exists?(:orders, :total_amount)

    # Add product features
    add_column :products, :active, :boolean, default: true unless column_exists?(:products, :active)
    add_column :products, :featured, :boolean, default: false unless column_exists?(:products, :featured)
    add_column :products, :stock_quantity, :integer, default: 0 unless column_exists?(:products, :stock_quantity)

    # Add user role
    add_column :users, :role, :integer, default: 0 unless column_exists?(:users, :role)

    # Add indexes
    add_index :orders, :status unless index_exists?(:orders, :status)
    add_index :products, :active unless index_exists?(:products, :active)
    add_index :products, :featured unless index_exists?(:products, :featured)
    add_index :users, :role unless index_exists?(:users, :role)
  end
end 