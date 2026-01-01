require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "valid note" do
    note = Note.new(user: users(:alice), color: "blue")
    assert note.valid?
  end

  test "validates color inclusion" do
    note = Note.new(user: users(:alice), color: "invalid")
    assert_not note.valid?
    assert_includes note.errors[:color], "is not included in the list"
  end

  test "allows nil color" do
    note = Note.new(user: users(:alice), color: nil)
    assert note.valid?
  end

  test "pinned scope returns pinned notes" do
    assert_includes Note.pinned, notes(:alice_pinned_note)
    assert_not_includes Note.pinned, notes(:alice_note)
  end

  test "unpinned scope returns unpinned notes" do
    assert_includes Note.unpinned, notes(:alice_note)
    assert_not_includes Note.unpinned, notes(:alice_pinned_note)
  end

  test "locked? returns true for recently locked notes" do
    note = notes(:alice_note)
    note.lock!(users(:alice))
    assert note.locked?
  end

  test "locked? returns false for old locks" do
    note = notes(:alice_note)
    note.update!(locked_at: 10.minutes.ago, locked_by: users(:alice))
    assert_not note.locked?
  end

  test "can_edit? returns true for owner" do
    note = notes(:alice_note)
    assert note.can_edit?(users(:alice))
  end

  test "can_edit? returns true for shared user with edit permission" do
    note = notes(:alice_note)
    assert note.can_edit?(users(:bob))
  end

  test "can_view? returns true for owner" do
    note = notes(:alice_note)
    assert note.can_view?(users(:alice))
  end

  test "can_view? returns true for shared user" do
    note = notes(:alice_note)
    assert note.can_view?(users(:bob))
  end
end
