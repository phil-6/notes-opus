require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
  end

  test "user can view notes index" do
    sign_in_as(@user)

    assert_selector "h1", text: "My Notes"
  end

  test "user can create a new note" do
    sign_in_as(@user)

    click_link "New Note"

    within "[role='dialog']" do
      fill_in "note_title", with: "Test Note Title"
      click_button "Create Note"
    end

    assert_text "Note created successfully"
  end

  test "user can edit a note" do
    sign_in_as(@user)
    note = notes(:alice_note)

    find("#edit-note-#{note.id}").click

    within "[role='dialog']" do
      fill_in "note_title", with: "Updated Title"
      click_button "Save"
    end

    assert_text "Note saved"
  end

  test "user can delete a note" do
    sign_in_as(@user)
    note = notes(:alice_note)

    accept_confirm do
      find("#delete-note-#{note.id}").click
    end

    assert_text "Note deleted"
  end

  test "user can pin and unpin a note" do
    sign_in_as(@user)
    note = notes(:alice_note)

    find("#pin-note-#{note.id}").click

    assert_selector "h2", text: "Pinned"

    find("#unpin-note-#{note.id}").click

    assert_no_selector "h2", text: "Pinned"
  end

  test "autosave does not create multiple notes" do
    sign_in_as(@user)
    initial_count = Note.count

    click_link "New Note"

    within "[role='dialog']" do
      fill_in "note_title", with: "Autosave Test"
      sleep 1.5
      fill_in "note_title", with: "Autosave Test Updated"
      sleep 1.5
      click_button "Create Note"
    end

    assert_text "Note created successfully"
    assert_equal initial_count + 1, Note.count, "Expected only one note to be created"
  end

  test "modal closes when clicking backdrop" do
    sign_in_as(@user)

    click_link "New Note"
    assert_selector "[role='dialog']"

    find(".fixed.inset-0.bg-black\\/50").click

    assert_no_selector "[role='dialog']"
  end

  test "modal closes when pressing escape" do
    sign_in_as(@user)

    click_link "New Note"
    assert_selector "[role='dialog']"

    find("body").send_keys(:escape)

    assert_no_selector "[role='dialog']"
  end

  test "color picker allows selecting note color" do
    sign_in_as(@user)

    click_link "New Note"

    within "[role='dialog']" do
      fill_in "note_title", with: "Colored Note"

      find(".color-swatch-blue").click
      assert_selector ".color-swatch-blue.selected"

      click_button "Create Note"
    end

    assert_text "Note created successfully"
    assert_equal "blue", Note.last.color
  end
end
