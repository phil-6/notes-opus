class SharedWith < ApplicationRecord
  belongs_to :note
  belongs_to :shared_with_user, class_name: "User"

  validates :shared_with_user_id, uniqueness: { scope: :note_id }
  validate :cannot_share_with_owner

  private
  def cannot_share_with_owner
    if note && shared_with_user_id == note.user_id
      errors.add(:shared_with_user, :cannot_share_with_owner)
    end
  end
end
