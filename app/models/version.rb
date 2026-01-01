class Version < ApplicationRecord
  belongs_to :note
  belongs_to :user

  CHANGE_TYPES = %w[edit title_change color_change].freeze

  validates :change_type, inclusion: { in: CHANGE_TYPES }, allow_nil: true

  scope :ordered, -> { order(created_at: :desc) }

  def title_changed?
    previous_title.present? && previous_title != title
  end

  def content_changed?
    previous_content.present? && previous_content != content
  end

  def color_changed?
    previous_color.present? && previous_color != color
  end

  def changes_summary
    changes = []
    changes << :title if title_changed?
    changes << :content if content_changed?
    changes << :color if color_changed?
    changes
  end
end
