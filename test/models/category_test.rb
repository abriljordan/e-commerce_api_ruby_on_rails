require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = FactoryBot.build(:category)
  end

  test "is valid with a name" do
    assert @category.valid?
  end

  test "is invalid without a name" do
    @category.name = nil
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "has many products" do
    @category.save!
    product1 = FactoryBot.create(:product, category: @category)
    product2 = FactoryBot.create(:product, category: @category)
    assert_includes @category.products, product1
    assert_includes @category.products, product2
  end

  test "has many sub_categories" do
    @category.save!
    sub1 = FactoryBot.create(:sub_category, category: @category)
    sub2 = FactoryBot.create(:sub_category, category: @category)
    assert_includes @category.sub_categories, sub1
    assert_includes @category.sub_categories, sub2
  end
end
