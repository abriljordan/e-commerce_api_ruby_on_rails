class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :title
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :landmark
      t.string :phone_number

      t.timestamps
    end
  end
end
