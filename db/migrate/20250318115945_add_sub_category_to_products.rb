class AddSubCategoryToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :sub_category, null: true, foreign_key: true
  end
end
