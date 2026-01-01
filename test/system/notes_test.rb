require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
  end

  test "user can view notes index" do
    sign_in_as(@user)

    assert_selector "#unpinned-notes"
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

  test "editing a note closes modal after save" do
    sign_in_as(@user)
    note = notes(:alice_note)

    find("#edit-note-#{note.id}").click

    within "[role='dialog']" do
      fill_in "note_title", with: "Updated via Edit"
      click_button "Save"
    end

    assert_no_selector "[role='dialog']"
  end

  test "creating note when empty state exists removes empty state" do
    # Delete all notes first
    @user.notes.destroy_all

    sign_in_as(@user)

    assert_text "No notes yet"

    click_link "New Note"

    within "[role='dialog']" do
      fill_in "note_title", with: "First Note"
      click_button "Create Note"
    end

    assert_text "Note created successfully"
    assert_no_text "No notes yet"
    assert_text "First Note"
  end

  test "pinning a note updates the page immediately" do
    sign_in_as(@user)
    note = notes(:alice_note)

    assert_no_selector "h2", text: "Pinned"

    find("#pin-note-#{note.id}").click

    assert_selector "h2", text: "Pinned"
    within "#pinned-notes" do
      assert_selector "[data-note-id='#{note.id}']"
    end
  end

  test "unpinning a note updates the page immediately" do
    note = notes(:alice_note)
    note.update!(pinned: true)

    sign_in_as(@user)

    assert_selector "h2", text: "Pinned"

    find("#unpin-note-#{note.id}").click

    assert_no_selector "h2", text: "Pinned"
    within "#unpinned-notes" do
      assert_selector "[data-note-id='#{note.id}']"
    end
  end

  test "user can navigate to version history" do
    sign_in_as(@user)
    note = notes(:alice_note)
    # Create a version first
    note.versions.create!(user: @user, title: note.title, content: "Old content")

    find("#edit-note-#{note.id}").click

    within "[role='dialog']" do
      click_link "View history"
    end

    assert_selector "h1", text: "Version History"
  end

  test "creating a note adds it to the list immediately" do
    sign_in_as(@user)

    click_link "New Note"

    within "[role='dialog']" do
      fill_in "note_title", with: "Immediate Update Test"
      click_button "Create Note"
    end

    # The note should appear in the list without page refresh
    assert_no_selector "[role='dialog']"
    assert_selector "#unpinned-notes [data-note-id]", text: "Immediate Update Test"
  end

  test "archived notes display archived timestamp" do
    note = notes(:alice_note)
    note.update!(archived_at: 2.days.ago)

    sign_in_as(@user)
    visit archived_notes_path

    assert_text "Archived"
  end

  test "notes are displayed in position order" do
    @user.notes.active.unpinned.destroy_all
    @user.notes.create!(title: "Position 2", position: 2)
    @user.notes.create!(title: "Position 0", position: 0)
    @user.notes.create!(title: "Position 1", position: 1)

    sign_in_as(@user)

    within "#unpinned-notes" do
      titles = all("[data-note-id] h3, [data-note-id] .text-sm").map(&:text)
      assert_equal ["Position 0", "Position 1", "Position 2"], titles.first(3)
    end
  end

  test "archiving a note removes it from the list immediately" do
    sign_in_as(@user)
    note = notes(:alice_note)

    assert_selector "[data-note-id='#{note.id}']"

    find("#archive-note-#{note.id}").click

    assert_no_selector "[data-note-id='#{note.id}']"
  end
end
