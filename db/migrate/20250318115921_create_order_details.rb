class CreateOrderDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :order_details do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :payment_id
      t.decimal :total

      t.timestamps
    end
  end
end
