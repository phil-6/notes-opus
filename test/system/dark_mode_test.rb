require "application_system_test_case"

class DarkModeTest < ApplicationSystemTestCase
  test "user can toggle dark mode" do
    user = users(:alice)
    sign_in_as(user)

    assert_no_selector "html.dark"

    find("#theme-toggle").click

    assert_selector "html.dark"

    find("#theme-toggle").click

    assert_no_selector "html.dark"
  end

  test "dark mode preference persists after page reload" do
    user = users(:alice)
    sign_in_as(user)

    find("#theme-toggle").click
    assert_selector "html.dark"

    visit notes_path

    assert_selector "html.dark"
  end

  test "sun and moon icons toggle visibility" do
    user = users(:alice)
    sign_in_as(user)

    # In light mode, moon icon should be visible, sun hidden
    within "#theme-toggle" do
      assert_selector ".moon-icon"
    end

    find("#theme-toggle").click

    # In dark mode, sun icon should be visible, moon hidden
    within "#theme-toggle" do
      assert_selector ".sun-icon"
    end
  end
end
