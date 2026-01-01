require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      display_name: "Test User"
    )
    assert user.valid?
  end

  test "requires email" do
    user = User.new(password: "password123", display_name: "Test")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "requires unique email" do
    user = User.new(
      email_address: users(:alice).email_address,
      password: "password123",
      display_name: "Test"
    )
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is already taken"
  end

  test "requires display name" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:display_name], "can't be blank"
  end

  test "requires password of at least 8 characters" do
    user = User.new(
      email_address: "test@example.com",
      password: "short",
      display_name: "Test"
    )
    assert_not user.valid?
  end

  test "normalizes email to lowercase" do
    user = User.new(email_address: "TEST@Example.COM")
    assert_equal "test@example.com", user.email_address
  end

  test "strips display name" do
    user = User.new(display_name: "  Test User  ")
    assert_equal "Test User", user.display_name
  end
end
