require "test_helper"

class CartTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @cart = FactoryBot.build(:cart, user: @user)
  end

  test "is valid with a user" do
    assert @cart.valid?
  end

  test "is invalid without a user" do
    @cart.user = nil
    assert_not @cart.valid?
    assert_includes @cart.errors[:user], "must exist"
  end

  test "belongs to the correct user" do
    @cart.save!
    assert_equal @user.id, @cart.user.id
  end
end
