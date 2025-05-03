require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @category = create(:category)
    @sub_category = create(:sub_category, category: @category)
    @product = Product.new(
      name: "Super Widget",
      description: "High-quality widget.",
      summary: "Popular widget product.",
      cover: "https://example.com/widget.jpg",
      category: @category,
      sub_category: @sub_category
    )
  end

  test "is valid with valid attributes" do
    assert @product.valid?
  end

  test "is invalid without a name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "is invalid without a description" do
    @product.description = nil
    assert_not @product.valid?
    assert_includes @product.errors[:description], "can't be blank"
  end

  test "belongs to a category" do
    assert_equal @category, @product.category
  end

  test "can optionally belong to a sub_category" do
    @product.sub_category = nil
    assert @product.valid?
  end

  test "is invalid without a category (enforced by DB)" do
    @product.category = nil
    assert_not @product.valid?
  end
end
