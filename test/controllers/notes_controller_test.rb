require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @note = notes(:alice_note)
    sign_in_as(@user)
  end

  test "should get index" do
    get notes_url
    assert_response :success
  end

  test "should get new" do
    get new_note_url
    assert_response :success
  end

  test "should create note" do
    assert_difference("Note.count") do
      post notes_url, params: { note: { title: "Test Note", color: "blue" } }
    end
    assert_redirected_to notes_url
  end

  test "should get edit" do
    get edit_note_url(@note)
    assert_response :success
  end

  test "should update note" do
    patch note_url(@note), params: { note: { title: "Updated Title" } }
    assert_redirected_to notes_url
    @note.reload
    assert_equal "Updated Title", @note.title
  end

  test "should destroy note" do
    # Notes must be archived before they can be deleted
    @note.archive!
    assert_difference("Note.count", -1) do
      delete note_url(@note)
    end
    assert_redirected_to archived_notes_url
  end

  test "should not destroy non-archived note" do
    assert_no_difference("Note.count") do
      delete note_url(@note)
    end
    assert_redirected_to notes_url
    assert_equal I18n.t("notes.must_archive_first"), flash[:alert]
  end

  test "should archive note" do
    patch archive_note_url(@note)
    assert_redirected_to notes_url
    @note.reload
    assert @note.archived?
  end

  test "should unarchive note" do
    @note.archive!
    patch unarchive_note_url(@note)
    assert_redirected_to archived_notes_url
    @note.reload
    assert_not @note.archived?
  end

  test "should get archived notes" do
    @note.archive!
    get archived_notes_url
    assert_response :success
  end

  test "should pin note" do
    patch pin_note_url(@note)
    assert_redirected_to notes_url
    @note.reload
    assert @note.pinned?
  end

  test "should unpin note" do
    @pinned = notes(:alice_pinned_note)
    patch unpin_note_url(@pinned)
    assert_redirected_to notes_url
    @pinned.reload
    assert_not @pinned.pinned?
  end

  test "should not edit other user's note" do
    other_note = notes(:bob_note)
    get edit_note_url(other_note)
    assert_redirected_to notes_url
  end

  test "should update note position" do
    note1 = notes(:alice_note)
    note2 = @user.notes.create!(title: "Second Note", position: 1)

    patch update_position_note_url(note2), params: { position: 0 }, as: :json
    assert_response :ok

    note2.reload
    note1.reload
    assert_equal 0, note2.position
    assert_equal 1, note1.position
  end

  test "position changes persist across requests" do
    # Create notes with known positions
    @user.notes.active.unpinned.destroy_all
    note1 = @user.notes.create!(title: "First", position: 0)
    note2 = @user.notes.create!(title: "Second", position: 1)
    note3 = @user.notes.create!(title: "Third", position: 2)

    # Move third note to first position
    patch update_position_note_url(note3), params: { position: 0 }, as: :json
    assert_response :ok

    # Verify database positions
    note1.reload
    note2.reload
    note3.reload
    assert_equal 0, note3.position, "Third note should be at position 0"
    assert_equal 1, note1.position, "First note should be at position 1"
    assert_equal 2, note2.position, "Second note should be at position 2"

    # Fetch the index page and verify order
    get notes_url
    assert_response :success
    assert_match(/Third.*First.*Second/m, response.body)
  end

  test "index returns notes ordered by position" do
    @user.notes.active.unpinned.destroy_all
    note3 = @user.notes.create!(title: "Third", position: 2)
    note1 = @user.notes.create!(title: "First", position: 0)
    note2 = @user.notes.create!(title: "Second", position: 1)

    get notes_url
    assert_response :success

    # The notes should appear in position order in the response
    assert_match(/First.*Second.*Third/m, response.body)
  end

  test "create note via turbo_stream prepends to list" do
    assert_difference("Note.count") do
      post notes_url, params: { note: { title: "New Note" } }, as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, 'turbo-stream action="prepend" target="unpinned-notes"'
  end

  test "create note via turbo_stream includes note card with title" do
    post notes_url, params: { note: { title: "My Shiny New Note" } }, as: :turbo_stream
    assert_response :success
    # The turbo stream response should include the note card with the title
    assert_includes response.body, "My Shiny New Note"
  end

  test "new note appears in index after creation" do
    post notes_url, params: { note: { title: "Newly Created Note" } }
    assert_redirected_to notes_url

    # Follow the redirect and check the note appears
    get notes_url
    assert_response :success
    assert_includes response.body, "Newly Created Note"
  end

  test "create note via turbo_stream clears modal" do
    post notes_url, params: { note: { title: "New Note" } }, as: :turbo_stream
    assert_response :success
    assert_includes response.body, 'turbo-stream action="update" target="modal"'
  end

  test "archived notes show archived_at timestamp" do
    @note.update!(archived_at: Time.current)
    get archived_notes_url
    assert_response :success
    assert_match(/Archived/, response.body)
  end

  private
  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password123" }
  end
end
