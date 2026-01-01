class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :connected_user, class_name: "User"

  validates :connected_user_id, uniqueness: { scope: :user_id }
  validate :cannot_connect_with_self

  private
  def cannot_connect_with_self
    if user_id == connected_user_id
      errors.add(:connected_user, :cannot_connect_with_self)
    end
  end
end
