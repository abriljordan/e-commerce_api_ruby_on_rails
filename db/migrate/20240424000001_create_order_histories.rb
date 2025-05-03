class CreateOrderHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :order_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :status, null: false
      t.text :note, null: false
      t.jsonb :metadata

      t.timestamps
    end

    add_index :order_histories, :status
    add_index :order_histories, :created_at
  end
end 