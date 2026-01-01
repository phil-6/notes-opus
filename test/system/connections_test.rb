require "application_system_test_case"

class ConnectionsTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
  end

  test "user can view connections page" do
    sign_in_as(@alice)
    visit connections_path

    assert_selector "h1", text: "Connections"
  end

  test "user can add a connection" do
    sign_in_as(@alice)
    visit connections_path

    fill_in placeholder: "Enter email address", with: @bob.email_address
    click_button "Add"

    assert_text "Connection added"
    assert_text @bob.display_name
  end

  test "user cannot add connection with invalid email" do
    sign_in_as(@alice)
    visit connections_path

    fill_in placeholder: "Enter email address", with: "notauser@example.com"
    click_button "Add"

    assert_text "No user found"
  end

  test "user can remove a connection" do
    # Create connection first
    Connection.create!(user: @alice, connected_user: @bob)

    sign_in_as(@alice)
    visit connections_path

    accept_confirm do
      click_button "Remove"
    end

    assert_text "Connection removed"
    assert_no_text @bob.display_name
  end
end
