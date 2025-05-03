class CreatePaymentDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_details do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :amount
      t.string :provider
      t.string :status

      t.timestamps
    end
  end
end
