class DropAddressesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :addresses
  end

  def down
    create_table :addresses do |t|
      t.string :street
      t.string :zipcode
      t.references :city, foreign_key: true
      t.timestamps
    end
  end
end
