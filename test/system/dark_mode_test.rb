require "application_system_test_case"

class DarkModeTest < ApplicationSystemTestCase
  test "user can toggle dark mode" do
    user = users(:alice)
    sign_in_as(user)

    assert_no_selector "html.dark"

    find("#dark-mode-toggle").click

    assert_selector "html.dark"

    find("#dark-mode-toggle").click

    assert_no_selector "html.dark"
  end

  test "dark mode preference persists after page reload" do
    user = users(:alice)
    sign_in_as(user)

    find("#dark-mode-toggle").click
    assert_selector "html.dark"

    visit notes_path

    assert_selector "html.dark"
  end
end
