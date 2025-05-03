class CreateProductAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :product_attributes do |t|
      t.string :attribute_type
      t.string :value

      t.timestamps
    end
  end
end
