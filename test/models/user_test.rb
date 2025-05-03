require "test_helper"

class UserTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  def setup
    @user = create(:user)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require a username" do
    @user.username = nil
    assert_not @user.valid?
  end

  test "should require a unique username" do
    duplicate_user = build(:user, username: @user.username)
    assert @user.save
    assert_not duplicate_user.valid?
  end

  test "should require an email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require a unique email" do
    duplicate_user = build(:user, email: @user.email.upcase)
    assert @user.save
    assert_not duplicate_user.valid?
  end

  test "should reject invalid email formats" do
    invalid_emails = [ "invalid@", "user@com", "test@.com", "test@example,com" ]
    invalid_emails.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email.inspect} should be invalid"
    end
  end

  test "should require a password of minimum length" do
    @user.password = "short"
    assert_not @user.valid?
  end

  test "should have associated cart" do
    assert_not_nil @user.cart
  end

  test "should have associated addresses" do
    assert_respond_to @user, :addresses
    assert_not_empty @user.addresses
  end

  test "should have associated orders" do
    assert_respond_to @user, :orders
    assert_not_empty @user.orders
  end

  test "should have associated wishlists" do
    assert_respond_to @user, :wishlists
    assert_not_empty @user.wishlists
  end
end
