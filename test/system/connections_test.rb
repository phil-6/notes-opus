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
    # Create a new user to connect with (not already connected via fixture)
    charlie = User.create!(
      email_address: "charlie@example.com",
      password: "password123",
      display_name: "Charlie Brown"
    )

    sign_in_as(@alice)
    visit connections_path

    fill_in placeholder: "Enter email address", with: charlie.email_address
    click_button "Add"

    assert_text "Connection added"
    assert_text charlie.display_name
  end

  test "user can send invitation for unknown email" do
    sign_in_as(@alice)
    visit connections_path

    fill_in placeholder: "Enter email address", with: "notauser@example.com"
    click_button "Add"

    assert_text "Invitation created for notauser@example.com"
    assert_text "notauser@example.com"
  end

  test "user can remove a connection" do
    # The alice_to_bob connection already exists via fixture
    sign_in_as(@alice)
    visit connections_path

    accept_confirm do
      click_button "Remove"
    end

    assert_text "Connection removed"
    assert_no_text @bob.display_name
  end
end
