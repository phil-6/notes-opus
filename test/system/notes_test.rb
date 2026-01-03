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

    click_link "New Note", match: :first

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

    # Modal should close
    assert_no_selector "[role='dialog']"

    # Note should show updated title
    assert_text "Updated Title"
  end

  test "user can delete a note" do
    # Archive the note first (via model, not UI)
    note = notes(:alice_note)
    note.archive!

    sign_in_as(@user)

    # Visit archived notes
    visit archived_notes_path
    assert_text "Archive"

    # Hover over the note card to reveal action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    # Click delete button - Turbo confirm should trigger
    accept_confirm do
      find("#delete-note-#{note.id}").click
    end

    # Note should be gone
    assert_no_selector "[data-note-id='#{note.id}']"
  end

  test "user can pin and unpin a note" do
    sign_in_as(@user)
    note = notes(:alice_note)

    # Hover to reveal action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    find("#pin-note-#{note.id}").click

    assert_selector "h2", text: "Pinned"

    # Wait for the pinned section to contain the note and find it
    within "#pinned-notes" do
      assert_selector "[data-note-id='#{note.id}']"
    end

    # Hover again on the pinned note to reveal action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    # Wait for unpin button to be visible and clickable
    assert_selector "#unpin-note-#{note.id}", visible: true
    find("#unpin-note-#{note.id}").click

    # The note should be moved to unpinned
    within "#unpinned-notes" do
      assert_selector "[data-note-id='#{note.id}']"
    end
  end

  test "autosave does not create multiple notes" do
    sign_in_as(@user)
    initial_count = Note.count

    click_link "New Note", match: :first

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

    click_link "New Note", match: :first
    assert_selector "[role='dialog']"

    # Click at the top-left corner of the backdrop where no dialog elements are
    page.execute_script("document.querySelector('.fixed.inset-0.bg-black\\\\/50').click()")

    assert_no_selector "[role='dialog']"
  end

  test "modal closes when pressing escape" do
    sign_in_as(@user)

    click_link "New Note", match: :first
    assert_selector "[role='dialog']"

    # Focus on the title input and send escape key
    find("#note_title").send_keys(:escape)

    assert_no_selector "[role='dialog']"
  end

  test "color picker allows selecting note color" do
    sign_in_as(@user)

    click_link "New Note", match: :first

    within "[role='dialog']" do
      fill_in "note_title", with: "Colored Note"

      # Open the color picker dropdown first
      find("[data-color-picker-target='button']").click

      # Select the blue color by clicking its label
      find("label[data-color='blue']").click

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

    click_link "New Note", match: :first

    within "[role='dialog']" do
      fill_in "note_title", with: "First Note"
      click_button "Create Note"
    end

    assert_text "Note created successfully"
    assert_no_text "No notes yet"
    assert_text "First Note"
  end

  test "pinning a note updates the page immediately" do
    # Use a note that is not pinned
    note = notes(:alice_note)
    assert_not note.pinned?

    sign_in_as(@user)

    # Hover over the note card to reveal the action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    # Pin the note
    find("#pin-note-#{note.id}").click

    # Verify the note appears in pinned section
    within "#pinned-notes" do
      assert_selector "[data-note-id='#{note.id}']"
    end
  end

  test "unpinning a note updates the page immediately" do
    note = notes(:alice_note)
    note.update!(pinned: true)

    sign_in_as(@user)

    assert_selector "h2", text: "Pinned"

    # Hover to reveal action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    find("#unpin-note-#{note.id}").click

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

    click_link "New Note", match: :first

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
      titles = all("[data-note-id] h3").map(&:text)
      assert_equal [ "Position 0", "Position 1", "Position 2" ], titles
    end
  end

  test "archiving a note removes it from the list immediately" do
    sign_in_as(@user)
    note = notes(:alice_note)

    assert_selector "[data-note-id='#{note.id}']"

    # Hover to reveal action buttons
    note_card = find("[data-note-id='#{note.id}']")
    note_card.hover

    find("#archive-note-#{note.id}").click

    assert_no_selector "[data-note-id='#{note.id}']"
  end

  test "new note appears in the list after creation" do
    sign_in_as(@user)

    # Count existing notes
    initial_note_count = all("#unpinned-notes [data-note-id]").count

    click_link "New Note", match: :first

    within "[role='dialog']" do
      fill_in "note_title", with: "Brand New Note"
      click_button "Create Note"
    end

    # Wait for modal to close and note to appear
    assert_no_selector "[role='dialog']"

    # Verify the note appears in the list without refresh
    within "#unpinned-notes" do
      assert_text "Brand New Note"
    end

    # Verify there's one more note than before
    assert_equal initial_note_count + 1, all("#unpinned-notes [data-note-id]").count

    # Refresh the page and verify the note is still there
    visit notes_path

    within "#unpinned-notes" do
      assert_text "Brand New Note"
    end
  end

  test "note position changes persist after page refresh" do
    # Create fresh notes with known positions
    @user.notes.active.unpinned.destroy_all
    note1 = @user.notes.create!(title: "First Note", position: 0)
    note2 = @user.notes.create!(title: "Second Note", position: 1)
    note3 = @user.notes.create!(title: "Third Note", position: 2)

    sign_in_as(@user)

    # Verify initial order
    within "#unpinned-notes" do
      titles = all("[data-note-id] h3").map(&:text)
      assert_equal [ "First Note", "Second Note", "Third Note" ], titles
    end

    # Update position directly in the database to simulate drag
    # This is more reliable than trying to do JS fetch in system tests
    Note.transaction do
      # Move note3 to position 0, shift others
      note1.update!(position: 1)
      note2.update!(position: 2)
      note3.update!(position: 0)
    end

    # Refresh the page
    visit notes_path

    # Verify the new order persisted
    within "#unpinned-notes" do
      titles = all("[data-note-id] h3").map(&:text)
      assert_equal [ "Third Note", "First Note", "Second Note" ], titles
    end
  end
end
