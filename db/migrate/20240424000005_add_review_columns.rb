class AddReviewColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :average_rating, :decimal, precision: 3, scale: 2, default: 0
    add_column :products, :review_count, :integer, default: 0
    add_column :products, :metadata, :jsonb, default: {}
    
    add_column :product_reviews, :approved, :boolean, default: false
    add_column :product_reviews, :metadata, :jsonb, default: {}
    
    add_index :products, :average_rating
    add_index :products, :review_count
    add_index :products, :metadata, using: :gin
    
    add_index :product_reviews, :approved
    add_index :product_reviews, :metadata, using: :gin
  end
end 