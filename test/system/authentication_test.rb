require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can sign up" do
    visit new_registration_path

    fill_in "Display name", with: "New User"
    fill_in "Email address", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm password", with: "password123"

    click_button "Create account"

    # Should be logged in and see the header
    assert_selector "header"
  end

  test "user can sign in and sign out" do
    user = users(:alice)

    visit new_session_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password123"

    click_button "Sign in"

    # Should see the header and user's name
    assert_selector "header"
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

    # Should still be on login page
    assert_selector "form#session-form"
  end

  test "sign up validation shows errors" do
    visit new_registration_path

    # Fill in invalid data
    fill_in "Display name", with: "Test"
    fill_in "Email address", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm password", with: "differentpassword"

    click_button "Create account"

    # Should stay on registration page with form still visible
    assert_selector "form#registration-form"
  end
end
