class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :notes, through: :taggings

  validates :name, presence: true, uniqueness: { scope: :user_id }

  normalizes :name, with: ->(n) { n.strip.downcase }
end
