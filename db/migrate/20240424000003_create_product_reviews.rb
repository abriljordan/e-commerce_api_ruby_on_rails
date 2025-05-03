class CreateProductReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :product_reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :order_item, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.integer :rating, null: false
      t.boolean :approved, default: false
      t.jsonb :metadata

      t.timestamps
    end

    add_index :product_reviews, [:user_id, :product_id], unique: true
    add_index :product_reviews, :rating
    add_index :product_reviews, :approved
  end
end 