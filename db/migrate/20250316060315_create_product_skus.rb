class CreateProductSkus < ActiveRecord::Migration[8.0]
  def change
    create_table :product_skus do |t|
      t.references :product, null: false, foreign_key: true
      t.references :size_attribute, null: false, foreign_key: { to_table: :product_attributes }
      t.references :color_attribute, null: false, foreign_key: { to_table: :product_attributes }
      t.string :sku
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity

      t.timestamps
    end
  end
end
