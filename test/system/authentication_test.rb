require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can sign up" do
    visit new_registration_path

    fill_in "Display name", with: "New User"
    fill_in "Email address", with: "newuser@example.com"
    fill_in "registrations_password", with: "password123"
    fill_in "Confirm password", with: "password123"

    click_button "Create account"

    assert_text "My Notes"
  end

  test "user can sign in and sign out" do
    user = users(:alice)

    visit new_session_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password123"

    click_button "Sign in"

    assert_text "My Notes"
    assert_text user.display_name

    find("#user-menu-button").click
    click_button "Sign out"

    assert_text "Sign in to your account"
  end

  test "user cannot sign in with wrong password" do
    user = users(:alice)

    visit new_session_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "wrongpassword"

    click_button "Sign in"

    assert_text "Invalid email address or password"
  end

  test "sign up validation shows errors" do
    visit new_registration_path

    fill_in "Email address", with: "invalid-email"
    fill_in "registrations_password", with: "short"

    click_button "Create account"

    assert_text "is not a valid email address"
  end
end
