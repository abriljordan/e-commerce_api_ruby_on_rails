require "test_helper"

class SubCategoryTest < ActiveSupport::TestCase
  def setup
    @category = FactoryBot.create(:category)
    @sub_category = FactoryBot.build(:sub_category, category: @category)
  end

  test "is valid with a name and category" do
    assert @sub_category.valid?
  end

  test "is invalid without a name" do
    @sub_category.name = nil
    assert_not @sub_category.valid?
    assert_includes @sub_category.errors[:name], "can't be blank"
  end

  test "is invalid without a category" do
    @sub_category.category = nil
    assert_not @sub_category.valid?
    assert_includes @sub_category.errors[:category], "must exist"
  end

  test "belongs to a category" do
    @sub_category.save!
    assert_equal @sub_category.category, @category
  end

  test "can have products" do
    @sub_category.save!
    product = FactoryBot.create(:product, sub_category: @sub_category)
    assert_includes @sub_category.products, product
  end
end
