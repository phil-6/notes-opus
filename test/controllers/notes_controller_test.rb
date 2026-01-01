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

  private
  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password123" }
  end
end
