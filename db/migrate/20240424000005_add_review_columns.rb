class AddReviewColumns < ActiveRecord::Migration[7.1]
  def change
    # Add columns to product_reviews table if they don't exist
    unless column_exists?(:product_reviews, :approved)
      add_column :product_reviews, :approved, :boolean, default: false
    end

    unless column_exists?(:product_reviews, :metadata)
      add_column :product_reviews, :metadata, :jsonb, default: {}
    end
    
    # Add indexes if they don't exist
    add_index :product_reviews, :approved unless index_exists?(:product_reviews, :approved)
    add_index :product_reviews, :metadata, using: :gin unless index_exists?(:product_reviews, :metadata, using: :gin)
  end
end 