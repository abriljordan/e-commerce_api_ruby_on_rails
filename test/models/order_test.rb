require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @order = FactoryBot.build(:order, user: @user)
  end

  test "is valid with a user and total_price" do
    assert @order.valid?
  end

  test "is invalid without a user" do
    @order.user = nil
    assert_not @order.valid?
    assert_includes @order.errors[:user], "must exist"
  end

  test "is invalid without a total_price" do
    @order.total_price = nil
    assert_not @order.valid?
    assert_includes @order.errors[:total_price], "can't be blank"
  end

  test "belongs to the correct user" do
    @order.save!
    assert_equal @user.id, @order.user.id
  end
end
