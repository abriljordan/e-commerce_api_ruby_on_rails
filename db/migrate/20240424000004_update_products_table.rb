class UpdateProductsTable < ActiveRecord::Migration[7.1]
  def change
    # Add base_price if it doesn't exist
    unless column_exists?(:products, :base_price)
      add_column :products, :base_price, :decimal, precision: 10, scale: 2, null: false
    end

    # Add featured if it doesn't exist
    unless column_exists?(:products, :featured)
      add_column :products, :featured, :boolean, default: false
    end

    # Add average_rating if it doesn't exist
    unless column_exists?(:products, :average_rating)
      add_column :products, :average_rating, :decimal, precision: 3, scale: 2
    end

    # Add review_count if it doesn't exist
    unless column_exists?(:products, :review_count)
      add_column :products, :review_count, :integer, default: 0
    end

    # Add metadata if it doesn't exist
    unless column_exists?(:products, :metadata)
      add_column :products, :metadata, :jsonb, default: {}
    end
    
    # Add indexes if they don't exist
    add_index :products, :featured unless index_exists?(:products, :featured)
    add_index :products, :average_rating unless index_exists?(:products, :average_rating)
    add_index :products, :metadata, using: :gin unless index_exists?(:products, :metadata, using: :gin)
  end
end 