class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :connections_as_user, class_name: "Connection", foreign_key: :user_id, dependent: :destroy
  has_many :connections_as_connected, class_name: "Connection", foreign_key: :connected_user_id, dependent: :destroy
  has_many :connected_users, through: :connections_as_user, source: :connected_user
  has_many :shared_notes, class_name: "SharedWith", foreign_key: :shared_with_user_id, dependent: :destroy
  has_many :notes_shared_with_me, through: :shared_notes, source: :note
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :inviter_id, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :display_name, with: ->(n) { n.strip }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
end
