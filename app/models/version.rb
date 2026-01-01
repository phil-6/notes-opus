class Version < ApplicationRecord
  belongs_to :note
  belongs_to :user

  scope :ordered, -> { order(created_at: :desc) }
end
