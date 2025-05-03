require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @cart = @user.cart
    @product = FactoryBot.create(:product)
    @product_sku = FactoryBot.create(:product_sku, product: @product)

    @cart_item = CartItem.new(
      cart: @cart,
      product: @product,
      product_sku: @product_sku,
      quantity: 2
    )
  end

  test "is valid with valid attributes" do
    assert @cart_item.valid?
  end

  test "is invalid without a cart" do
    @cart_item.cart = nil
    assert_not @cart_item.valid?
    assert_includes @cart_item.errors[:cart], "must exist"
  end

  test "is invalid without a product" do
    @cart_item.product = nil
    assert_not @cart_item.valid?
    assert_includes @cart_item.errors[:product], "must exist"
  end

  test "is invalid without a product_sku" do
    @cart_item.product_sku = nil
    assert_not @cart_item.valid?
    assert_includes @cart_item.errors[:product_sku], "must exist"
  end

  test "is invalid with zero quantity" do
    @cart_item.quantity = 0
    assert_not @cart_item.valid?
    assert_includes @cart_item.errors[:quantity], "must be greater than 0"
  end
end
