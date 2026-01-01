class Note < ApplicationRecord
  belongs_to :user
  belongs_to :locked_by, class_name: "User", optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :shared_withs, dependent: :destroy
  has_many :shared_users, through: :shared_withs, source: :shared_with_user
  has_many :versions, dependent: :destroy

  has_rich_text :content

  COLORS = %w[
    slate gray zinc neutral stone
    red orange amber yellow lime
    green emerald teal cyan sky
    blue indigo violet purple fuchsia
    pink rose
  ].freeze

  validates :color, inclusion: { in: COLORS }, allow_nil: true

  scope :pinned, -> { where(pinned: true).order(position: :asc) }
  scope :unpinned, -> { where(pinned: false).order(position: :asc) }
  scope :ordered, -> { order(position: :asc) }

  def locked?
    locked_at.present? && locked_at > 5.minutes.ago
  end

  def lock!(user)
    update!(locked_at: Time.current, locked_by: user)
  end

  def unlock!
    update!(locked_at: nil, locked_by: nil)
  end

  def can_edit?(user)
    return true if self.user == user
    shared_withs.exists?(shared_with_user: user, can_edit: true)
  end

  def can_view?(user)
    return true if self.user == user
    shared_withs.exists?(shared_with_user: user)
  end
end
