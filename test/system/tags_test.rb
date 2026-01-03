require "application_system_test_case"

class TagsTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
  end

  test "user can view tags page" do
    sign_in_as(@user)
    visit tags_path

    assert_selector "h1", text: "Tags"
  end

  test "user can create a new tag" do
    sign_in_as(@user)
    visit tags_path

    fill_in placeholder: "Tag name", with: "New Test Tag"
    click_button "Create"

    # Tag should appear in the list (turbo_stream updates the list)
    assert_text "new test tag"
  end

  test "user can delete a tag" do
    sign_in_as(@user)
    tag = tags(:work)

    visit tags_path

    accept_confirm do
      within "#tag_#{tag.id}" do
        click_button "Delete"
      end
    end

    assert_text "Tag deleted"
  end

  test "tag shows note count" do
    sign_in_as(@user)
    visit tags_path

    # Alice has a work tag associated with her note
    within "#tag_#{tags(:work).id}" do
      assert_text "note"
    end
  end
end
