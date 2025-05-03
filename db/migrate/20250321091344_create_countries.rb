class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :iso_code

      t.timestamps
    end
    add_index :countries, :name, unique: true
  end
end
