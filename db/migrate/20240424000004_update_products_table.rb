class UpdateProductsTable < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :price, :base_price
    add_column :products, :active, :boolean, default: true
    add_column :products, :featured, :boolean, default: false
    add_column :products, :average_rating, :decimal, precision: 3, scale: 2
    add_column :products, :review_count, :integer, default: 0
    add_column :products, :metadata, :jsonb, default: {}
    
    add_index :products, :active
    add_index :products, :featured
    add_index :products, :average_rating
    add_index :products, :metadata, using: :gin
  end
end 